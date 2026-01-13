<#
.SYNOPSIS
    Estimates monthly costs for Azure Cloud Architecture deployment.

.DESCRIPTION
    This script provides estimated monthly costs for different environments.
    Costs are based on Sweden Central region pricing and are approximate.

.PARAMETER Environment
    Environment to estimate costs for (dev, staging, prod, all). Default: all

.EXAMPLE
    .\cost-estimate.ps1
    .\cost-estimate.ps1 -Environment prod

.NOTES
    Author: Mohammad Othman
    Prices are estimates and may vary. Check Azure Pricing Calculator for accurate quotes.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("dev", "staging", "prod", "all")]
    [string]$Environment = "all"
)

# Pricing data (approximate USD/month for Sweden Central)
$pricing = @{
    VM = @{
        "Standard_B1s"     = 10
        "Standard_B2s_v2"  = 40
        "Standard_D2s_v3"  = 85
    }
    Disk = @{
        "Standard_LRS"     = 3
        "StandardSSD_LRS"  = 5
        "Premium_LRS"      = 18
    }
    SQL = @{
        "Basic"            = 5
        "S0"               = 15
        "S1"               = 30
    }
    Storage = @{
        "LRS"              = 3
        "GRS"              = 5
    }
    LoadBalancer        = 22
    KeyVault            = 1
    LogAnalytics        = 3
    PublicIP            = 4
}

function Get-EnvironmentCost {
    param([string]$Env)

    switch ($Env) {
        "dev" {
            $vmCost = $pricing.VM["Standard_B2s_v2"] * 2
            $diskCost = $pricing.Disk["Standard_LRS"] * 2
            $sqlCost = $pricing.SQL["Basic"]
            $storageCost = $pricing.Storage["LRS"]
            $lbCost = $pricing.LoadBalancer
            $kvCost = $pricing.KeyVault
            $logCost = $pricing.LogAnalytics
            $pipCost = $pricing.PublicIP
        }
        "staging" {
            $vmCost = $pricing.VM["Standard_B2s_v2"] * 3
            $diskCost = $pricing.Disk["StandardSSD_LRS"] * 3
            $sqlCost = $pricing.SQL["S0"]
            $storageCost = $pricing.Storage["LRS"]
            $lbCost = $pricing.LoadBalancer
            $kvCost = $pricing.KeyVault
            $logCost = $pricing.LogAnalytics * 2
            $pipCost = $pricing.PublicIP
        }
        "prod" {
            $vmCost = $pricing.VM["Standard_D2s_v3"] * 3
            $diskCost = $pricing.Disk["Premium_LRS"] * 3
            $sqlCost = $pricing.SQL["S1"]
            $storageCost = $pricing.Storage["GRS"] * 5
            $lbCost = $pricing.LoadBalancer
            $kvCost = $pricing.KeyVault
            $logCost = $pricing.LogAnalytics * 4
            $pipCost = $pricing.PublicIP
        }
    }

    return @{
        Environment  = $Env
        Compute      = $vmCost
        Disks        = $diskCost
        Database     = $sqlCost
        Storage      = $storageCost
        LoadBalancer = $lbCost
        KeyVault     = $kvCost
        LogAnalytics = $logCost
        PublicIP     = $pipCost
        Total        = $vmCost + $diskCost + $sqlCost + $storageCost + $lbCost + $kvCost + $logCost + $pipCost
    }
}

function Show-CostTable {
    param([hashtable]$Cost)

    $envName = $Cost.Environment.ToUpper()

    Write-Host ""
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "  Environment: $envName" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Resource                     Cost (USD/month)" -ForegroundColor Gray
    Write-Host "  -------------------------    ----------------" -ForegroundColor Gray
    Write-Host "  Virtual Machines             `$$($Cost.Compute.ToString().PadLeft(6))"
    Write-Host "  OS Disks                     `$$($Cost.Disks.ToString().PadLeft(6))"
    Write-Host "  SQL Database                 `$$($Cost.Database.ToString().PadLeft(6))"
    Write-Host "  Storage Account              `$$($Cost.Storage.ToString().PadLeft(6))"
    Write-Host "  Load Balancer                `$$($Cost.LoadBalancer.ToString().PadLeft(6))"
    Write-Host "  Key Vault                    `$$($Cost.KeyVault.ToString().PadLeft(6))"
    Write-Host "  Log Analytics                `$$($Cost.LogAnalytics.ToString().PadLeft(6))"
    Write-Host "  Public IP                    `$$($Cost.PublicIP.ToString().PadLeft(6))"
    Write-Host "  -------------------------    ----------------" -ForegroundColor Gray
    Write-Host "  TOTAL (Monthly)              `$$($Cost.Total.ToString().PadLeft(6))" -ForegroundColor Green
    Write-Host "  TOTAL (Annual)               `$$(($Cost.Total * 12).ToString().PadLeft(6))" -ForegroundColor Green
}

# Main execution
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       Azure Cloud Architecture - Cost Estimation" -ForegroundColor Cyan
Write-Host "                   Sweden Central Region" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$environments = if ($Environment -eq "all") { @("dev", "staging", "prod") } else { @($Environment) }

foreach ($env in $environments) {
    $cost = Get-EnvironmentCost -Env $env
    Show-CostTable -Cost $cost
}

Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "  Notes" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "  * Prices are estimates based on Sweden Central region" -ForegroundColor Gray
Write-Host "  * Actual costs may vary based on usage patterns" -ForegroundColor Gray
Write-Host "  * Data transfer costs are not included" -ForegroundColor Gray
Write-Host "  * Reserved instances can reduce VM costs by ~40%" -ForegroundColor Gray
Write-Host "  * Use Azure Pricing Calculator for accurate quotes" -ForegroundColor Gray

Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "  Cost Optimization Tips" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "  1. Use Azure Reserved Instances for predictable workloads" -ForegroundColor White
Write-Host "  2. Auto-shutdown dev VMs outside business hours" -ForegroundColor White
Write-Host "  3. Use Azure Hybrid Benefit for Windows workloads" -ForegroundColor White
Write-Host "  4. Review and right-size VMs based on utilization" -ForegroundColor White
Write-Host "  5. Use storage lifecycle policies to archive old data" -ForegroundColor White
Write-Host ""
