<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psm1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script

Describe "Import-SmoAssemblies" {
    It "in a new Powershell process, SMO is not available" {
        $sue = powershell.exe -noprofile -nologo -command "try { `$bob = new-object Microsoft.SqlServer.Management.Common.ServerConnection} catch{} ; return `$bob"
        $sue | Should Be $null
    }

    It "in a new Powershell process, Import-SmoAssemblies is not available" {
        $sue = powershell.exe -noprofile -nologo -command "`$bob = Get-Command `"Import-SmoAssemblie[s]`"; return `$bob" <#I THINK [s] is treated as a wild card, looking for and of the characters in the braces. Just one, in this case.#>
        $sue | Should Be $null
    }

    It "in a new Powershell process, Import-SmoAssemblies is available after we create it." {
        $sue = powershell.exe -noprofile -nologo -command "using module '$here\$sut'; `$bob = Get-Command `"Import-SmoAssemblie[s]`"; return `$bob.Name"
        $sue | Should Be 'Import-SmoAssemblies'
    }

    It "in a new Powershell process after running Import-SmoAssemblies, I can instantiate an SMO ServerConnection" {
        $sue = powershell.exe -noprofile -nologo -command "using module '$here\$sut'; Import-SmoAssemblies ; try { `$bob = new-object Microsoft.SqlServer.Management.Common.ServerConnection} catch{} ; return `$bob.GetType().Name"
        $sue | Should Be 'ServerConnection' <#because apparently powershell.exe gives you arrays?#>
    }
}
