<#
.SYNOPSIS
    Destroys Azure Cloud Architecture infrastructure.

.DESCRIPTION
    This script safely tears down all deployed Azure resources.
    Includes confirmation prompts and safety checks.

.PARAMETER Environment
    Target environment to destroy (dev, staging, prod). Default: dev

.PARAMETER AutoApprove
    Skip confirmation prompts (use with caution)

.EXAMPLE
    .\destroy.ps1 -Environment dev
    .\destroy.ps1 -Environment staging -AutoApprove

.NOTES
    Author: Mohammad Othman
    Requires: Azure CLI, Terraform, PowerShell 7+
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",

    [Parameter()]
    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Join-Path (Split-Path -Parent $ScriptRoot) "terraform"

# Output functions
function Write-Step {
    param([string]$Step, [string]$Total, [string]$Message)
    Write-Host ""
    Write-Host "[$Step/$Total] $Message" -ForegroundColor Cyan
}
function Write-Status {
    param([string]$Status, [string]$Message, [string]$Color = "White")
    Write-Host "      [$Status] $Message" -ForegroundColor $Color
}
function Write-Ok { param([string]$Message) Write-Status -Status "OK" -Message $Message -Color Green }
function Write-Fail { param([string]$Message) Write-Status -Status "FAIL" -Message $Message -Color Red }
function Write-Warn { param([string]$Message) Write-Status -Status "WARN" -Message $Message -Color Yellow }
function Write-Info { param([string]$Message) Write-Status -Status "INFO" -Message $Message -Color Gray }

Write-Host ""
Write-Host "============================================================" -ForegroundColor Red
Write-Host "       Azure Cloud Architecture - DESTROY Script" -ForegroundColor Red
Write-Host "                       WARNING" -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Red
Write-Host ""
Write-Host "  Environment: $Environment" -ForegroundColor White
Write-Host ""
Write-Host "  This will PERMANENTLY DELETE all resources!" -ForegroundColor Yellow
Write-Host ""

# Safety check for production
if ($Environment -eq "prod" -and -not $AutoApprove) {
    Write-Host "------------------------------------------------------------" -ForegroundColor Red
    Write-Host "  PRODUCTION ENVIRONMENT DETECTED" -ForegroundColor Red
    Write-Host "------------------------------------------------------------" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "  Type 'DESTROY-PROD' to confirm"
    if ($confirm -ne "DESTROY-PROD") {
        Write-Host ""
        Write-Info "Destruction cancelled"
        exit 0
    }
}

# Confirmation prompt
if (-not $AutoApprove) {
    Write-Host ""
    $response = Read-Host "  Are you sure you want to continue? (yes/no)"
    if ($response -ne "yes") {
        Write-Host ""
        Write-Info "Destruction cancelled"
        exit 0
    }
}

# Check Azure login
Write-Step -Step "1" -Total "3" -Message "Checking Azure authentication..."
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Fail "Not logged into Azure"
    Write-Host "      Run 'az login' first" -ForegroundColor Gray
    exit 1
}
Write-Ok "Authenticated: $($account.user.name)"

# Get SSH key for variable
$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"
if (Test-Path $sshKeyPath) {
    $sshKey = (Get-Content $sshKeyPath -Raw).Trim()
} else {
    $sshKey = "ssh-rsa placeholder"
}

# Get Azure AD info
$currentUser = az ad signed-in-user show 2>$null | ConvertFrom-Json
$aadUsername = if ($currentUser) { $currentUser.userPrincipalName } else { "admin@example.com" }
$aadObjectId = if ($currentUser) { $currentUser.id } else { "00000000-0000-0000-0000-000000000000" }

# Run Terraform destroy
Write-Step -Step "2" -Total "3" -Message "Destroying infrastructure..."

$tfvarsFile = Join-Path $TerraformDir "environments\$Environment.tfvars"

Push-Location $TerraformDir
try {
    # Initialize if needed
    if (-not (Test-Path ".terraform")) {
        Write-Info "Initializing Terraform..."
        terraform init -input=false 2>&1 | Out-Null
    }

    $destroyArgs = @(
        "destroy",
        "-var-file=$tfvarsFile",
        "-var=admin_ssh_public_key=$sshKey",
        "-var=aad_admin_username=$aadUsername",
        "-var=aad_admin_object_id=$aadObjectId"
    )

    if ($AutoApprove) {
        $destroyArgs += "-auto-approve"
    }

    terraform @destroyArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Terraform destroy failed"
        exit 1
    }

    Write-Ok "Infrastructure destroyed"

} finally {
    Pop-Location
}

# Clean up local state
Write-Step -Step "3" -Total "3" -Message "Cleaning up local files..."

$filesToClean = @(
    (Join-Path $TerraformDir "tfplan"),
    (Join-Path $TerraformDir ".terraform.lock.hcl")
)

foreach ($file in $filesToClean) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Info "Removed: $(Split-Path $file -Leaf)"
    }
}

Write-Ok "Cleanup complete"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "          Environment '$Environment' Destroyed" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
