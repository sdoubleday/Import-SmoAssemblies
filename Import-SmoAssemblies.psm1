function Import-SmoAssemblies {
<#
.Synopsis
Loads the SQL Server Management Objects (SMO) unless one or more of those 
assemblies is already loaded.
From http://msdn.microsoft.com/en-us/library/hh245202.aspx
#>

<#SD Edit - I moved the IF statement from right after we create $verifyAssemblies to JUST contain the update-formatdata statement.
I also added an else version that will refresh the formatdata without adding formats.
This will always load the assemblies and at least update the formatdata. If the assemblies existed already, then it will not
ADD to the formatdata.
#>
          [CmdletBinding(
                     #V3.0 feature
                     #,
                     #PositionalBinding=$True
                     )]
        PARAM()

    $verifyAssemblies =  [appdomain]::currentdomain.getassemblies() | Where-Object {$_.FullName -like "Microsoft.SqlServer.*"} 


        $ErrorActionPreference = "Stop"

        $sqlpsreg=(gci "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.SqlServer.Management.PowerShell.sqlps*")[0].name.replace("HKEY_LOCAL_MACHINE","HKLM:")

        if (Get-ChildItem $sqlpsreg -ErrorAction "SilentlyContinue")
        {
            throw "SQL Server Provider for Windows PowerShell is not installed."
        }
        else
        {
            $item = Get-ItemProperty $sqlpsreg
            $sqlpsPath = [System.IO.Path]::GetDirectoryName($item.Path)
        }


        $assemblylist = 
        "Microsoft.SqlServer.Management.Common",
        "Microsoft.SqlServer.Smo",
        "Microsoft.SqlServer.Dmf ",
        "Microsoft.SqlServer.Instapi ",
        "Microsoft.SqlServer.SqlWmiManagement ",
        "Microsoft.SqlServer.ConnectionInfo ",
        "Microsoft.SqlServer.SmoExtended ",
        "Microsoft.SqlServer.SqlTDiagM ",
        "Microsoft.SqlServer.SString ",
        "Microsoft.SqlServer.Management.RegisteredServers ",
        "Microsoft.SqlServer.Management.Sdk.Sfc ",
        "Microsoft.SqlServer.SqlEnum ",
        "Microsoft.SqlServer.RegSvrEnum ",
        "Microsoft.SqlServer.WmiEnum ",
        "Microsoft.SqlServer.ServiceBrokerEnum ",
        "Microsoft.SqlServer.ConnectionInfoExtended ",
        "Microsoft.SqlServer.Management.Collector ",
        "Microsoft.SqlServer.Management.CollectorEnum",
        "Microsoft.SqlServer.Management.Dac",
        "Microsoft.SqlServer.Management.DacEnum",
        "Microsoft.SqlServer.Management.Utility"

        $debugOut = "Loading SMO assemblies:"
        Write-Debug $debugOut
        Write-Verbose $debugOut
        foreach ($asm in $assemblylist)
        {
            $debugOut = "Loading $asm..."
            Write-Debug $debugOut
            Write-Verbose $debugOut
            $asm = [System.Reflection.Assembly]::LoadWithPartialName($asm)
        }
        $debugOut = "Done Loading SMO assemblies."
        Write-Debug $debugOut
        Write-Verbose $debugOut

        Push-Location
        cd $sqlpsPath

        IF ($verifyAssemblies.Count -eq 0) {
            <#Cheap hack to work with SQL Server 2016 (interoperability with 2012 and 2014 not known)#>
            TRY {update-FormatData -prependpath SQLProvider.Format.ps1xml } CATCH { cd "$sqlpsPath\..\Powershell\Modules\SQLPS" ;update-FormatData -prependpath SQLProvider.Format.ps1xml }
        }
        ELSE {
            <#This CMDLET reloads the format files it already loaded, so it shouldn't need any similar 2016 hacks.#>
            update-FormatData 
        }    
        Pop-Location
    

}

Export-ModuleMember -Function "Import-SmoAssemblies"
