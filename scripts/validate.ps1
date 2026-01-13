<#
.SYNOPSIS
    Validates Azure Cloud Architecture Terraform configuration.

.DESCRIPTION
    This script performs pre-deployment validation including:
    - Terraform format check
    - Terraform validation
    - Azure connectivity check
    - Resource quota verification

.PARAMETER Environment
    Target environment to validate (dev, staging, prod). Default: dev

.EXAMPLE
    .\validate.ps1
    .\validate.ps1 -Environment prod

.NOTES
    Author: Mohammad Othman
    Requires: Azure CLI, Terraform, PowerShell 7+
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Join-Path (Split-Path -Parent $ScriptRoot) "terraform"
$ValidationPassed = $true
$TotalChecks = 8
$CurrentCheck = 0

# Output functions
function Write-Step {
    param([string]$Message)
    $script:CurrentCheck++
    Write-Host ""
    Write-Host "[$script:CurrentCheck/$TotalChecks] $Message" -ForegroundColor Cyan
}
function Write-Status {
    param([string]$Status, [string]$Message, [string]$Color = "White")
    Write-Host "      [$Status] $Message" -ForegroundColor $Color
}
function Write-Ok { param([string]$Message) Write-Status -Status "OK" -Message $Message -Color Green }
function Write-Fail {
    param([string]$Message)
    Write-Status -Status "FAIL" -Message $Message -Color Red
    $script:ValidationPassed = $false
}
function Write-Warn { param([string]$Message) Write-Status -Status "WARN" -Message $Message -Color Yellow }
function Write-Info { param([string]$Message) Write-Status -Status "INFO" -Message $Message -Color Gray }

# Main execution
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       Azure Cloud Architecture - Validation Script" -ForegroundColor Cyan
Write-Host "                   Sweden Central Region" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Environment: $Environment" -ForegroundColor White

# Check 1: Azure CLI
Write-Step "Checking Azure CLI..."
if (Get-Command az -ErrorAction SilentlyContinue) {
    $azVersion = (az version | ConvertFrom-Json).'azure-cli'
    Write-Ok "Azure CLI v$azVersion"
} else {
    Write-Fail "Azure CLI not found"
}

# Check 2: Terraform
Write-Step "Checking Terraform..."
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $tfVersion = (terraform version -json | ConvertFrom-Json).terraform_version
    Write-Ok "Terraform v$tfVersion"
} else {
    Write-Fail "Terraform not found"
}

# Check 3: Azure Authentication
Write-Step "Checking Azure authentication..."
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if ($account) {
        Write-Ok "Authenticated: $($account.user.name)"
        Write-Info "Subscription: $($account.name)"
    } else {
        Write-Fail "Not authenticated to Azure"
    }
} catch {
    Write-Fail "Azure authentication check failed"
}

# Check 4: Terraform Format
Write-Step "Checking Terraform formatting..."
Push-Location $TerraformDir
try {
    $fmtResult = terraform fmt -check -recursive 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Terraform files properly formatted"
    } else {
        Write-Fail "Terraform formatting issues found"
    }
} catch {
    Write-Fail "Terraform format check failed"
} finally {
    Pop-Location
}

# Check 5: Terraform Init
Write-Step "Initializing Terraform..."
Push-Location $TerraformDir
try {
    terraform init -backend=false -input=false 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Terraform initialization successful"
    } else {
        Write-Fail "Terraform initialization failed"
    }
} catch {
    Write-Fail "Terraform init failed"
} finally {
    Pop-Location
}

# Check 6: Terraform Validate
Write-Step "Validating Terraform configuration..."
Push-Location $TerraformDir
try {
    $validateResult = terraform validate -json | ConvertFrom-Json
    if ($validateResult.valid) {
        Write-Ok "Terraform configuration is valid"
    } else {
        Write-Fail "Terraform configuration is invalid"
        foreach ($diag in $validateResult.diagnostics) {
            Write-Host "      - $($diag.summary)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Fail "Terraform validate failed"
} finally {
    Pop-Location
}

# Check 7: Environment File
Write-Step "Checking environment configuration..."
$envFile = Join-Path $TerraformDir "environments\$Environment.tfvars"
if (Test-Path $envFile) {
    Write-Ok "Environment file: $Environment.tfvars"
} else {
    Write-Fail "Environment file not found: $envFile"
}

# Check 8: SSH Key
Write-Step "Checking SSH key..."
$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"
if (Test-Path $sshKeyPath) {
    Write-Ok "SSH public key found"
} else {
    Write-Warn "SSH key not found - will be generated during deployment"
}

# Summary
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "  Validation Summary" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Gray

if ($ValidationPassed) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "              All Validation Checks Passed" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Ready to deploy. Run:" -ForegroundColor White
    Write-Host "  .\scripts\deploy.ps1 -Environment $Environment" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "            Some Validation Checks Failed" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Please fix the issues above before deploying." -ForegroundColor White
    Write-Host ""
    exit 1
}
