<#
.SYNOPSIS
    Deploys Azure Cloud Architecture infrastructure using Terraform.

.DESCRIPTION
    This script orchestrates the full deployment of Azure infrastructure.
    It handles validation, planning, and applying Terraform configurations.

.PARAMETER Environment
    Target environment (dev, staging, prod). Default: dev

.PARAMETER AutoApprove
    Skip confirmation prompts for terraform apply

.PARAMETER PlanOnly
    Only run terraform plan without applying

.EXAMPLE
    .\deploy.ps1 -Environment dev
    .\deploy.ps1 -Environment prod -AutoApprove
    .\deploy.ps1 -Environment staging -PlanOnly

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
    [switch]$AutoApprove,

    [Parameter()]
    [switch]$PlanOnly
)

# Script configuration
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

function Test-Prerequisites {
    Write-Step -Step "1" -Total "4" -Message "Checking prerequisites..."

    # Check Azure CLI
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Fail "Azure CLI not found"
        Write-Host "      Install from https://docs.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Gray
        exit 1
    }
    $azVersion = (az version | ConvertFrom-Json).'azure-cli'
    Write-Ok "Azure CLI v$azVersion"

    # Check Terraform
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Fail "Terraform not found"
        Write-Host "      Install from https://www.terraform.io/downloads" -ForegroundColor Gray
        exit 1
    }
    $tfVersion = (terraform version -json | ConvertFrom-Json).terraform_version
    Write-Ok "Terraform v$tfVersion"

    # Check Azure login
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Fail "Not logged into Azure"
        Write-Host "      Run 'az login' first" -ForegroundColor Gray
        exit 1
    }
    Write-Ok "Authenticated: $($account.user.name)"
    Write-Info "Subscription: $($account.name)"
}

function Get-SSHKey {
    $sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"

    if (-not (Test-Path $sshKeyPath)) {
        Write-Warn "SSH key not found at $sshKeyPath"
        Write-Info "Generating new SSH key pair..."

        $sshDir = "$env:USERPROFILE\.ssh"
        if (-not (Test-Path $sshDir)) {
            New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        }

        ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""' -q
        Write-Ok "SSH key pair generated"
    }

    $sshKey = Get-Content $sshKeyPath -Raw
    return $sshKey.Trim()
}

function Get-AzureADInfo {
    $currentUser = az ad signed-in-user show 2>$null | ConvertFrom-Json

    if (-not $currentUser) {
        Write-Warn "Could not get Azure AD user info"
        return @{
            Username = "admin@example.com"
            ObjectId = "00000000-0000-0000-0000-000000000000"
        }
    }

    return @{
        Username = $currentUser.userPrincipalName
        ObjectId = $currentUser.id
    }
}

function Initialize-Terraform {
    Write-Step -Step "2" -Total "4" -Message "Initializing Terraform..."

    Push-Location $TerraformDir
    try {
        terraform init -upgrade 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Terraform init failed"
            exit 1
        }
        Write-Ok "Terraform initialized"
    }
    finally {
        Pop-Location
    }
}

function Invoke-TerraformPlan {
    param([string]$SSHKey, [hashtable]$AzureADInfo)

    Write-Step -Step "3" -Total "4" -Message "Planning infrastructure..."

    $tfvarsFile = Join-Path $TerraformDir "environments\$Environment.tfvars"

    Push-Location $TerraformDir
    try {
        $planArgs = @(
            "plan",
            "-var-file=$tfvarsFile",
            "-var=admin_ssh_public_key=$SSHKey",
            "-var=aad_admin_username=$($AzureADInfo.Username)",
            "-var=aad_admin_object_id=$($AzureADInfo.ObjectId)",
            "-out=tfplan"
        )

        terraform @planArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Terraform plan failed"
            exit 1
        }

        Write-Ok "Plan completed"
    }
    finally {
        Pop-Location
    }
}

function Invoke-TerraformApply {
    Write-Step -Step "4" -Total "4" -Message "Applying configuration..."

    Push-Location $TerraformDir
    try {
        $applyArgs = @("apply")

        if ($AutoApprove) {
            $applyArgs += "-auto-approve"
        }

        $applyArgs += "tfplan"

        terraform @applyArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Terraform apply failed"
            exit 1
        }

        Write-Ok "Infrastructure deployed"
    }
    finally {
        Pop-Location
    }
}

function Show-Outputs {
    Write-Host ""
    Write-Host "------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "  Deployment Outputs" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor Gray

    Push-Location $TerraformDir
    try {
        terraform output
    }
    finally {
        Pop-Location
    }
}

# Main execution
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       Azure Cloud Architecture - Deployment Script" -ForegroundColor Cyan
Write-Host "                   Sweden Central Region" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Environment:  $Environment" -ForegroundColor White
Write-Host "  Plan Only:    $PlanOnly" -ForegroundColor White
Write-Host "  Auto Approve: $AutoApprove" -ForegroundColor White

# Run deployment steps
Test-Prerequisites
$sshKey = Get-SSHKey
$azureADInfo = Get-AzureADInfo
Initialize-Terraform
Invoke-TerraformPlan -SSHKey $sshKey -AzureADInfo $azureADInfo

if (-not $PlanOnly) {
    Invoke-TerraformApply
    Show-Outputs
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "                  Deployment Complete" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
