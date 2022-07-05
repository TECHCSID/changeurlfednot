try
{
    # Création du point d'entrée au registre HKU (s'il n'existe pas)
    if($false -eq (Test-Path HKU:\ ))
    {
        New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
    }

    $results = ""

    # Récupération des répertoires enfants dans la ruche HKEY_USERS (Les users justement)       
    $hkuEntries = Get-ChildItem -Path HKU:\ |  Select-Object
    # on itère sur chaque user afin de recherche une entrée d'enregistrement d'URI Scheme pour iNot
    foreach($userEntry in $hkuEntries)
    {
        $fullGenapiKeyPath = $userEntry.Name + "\SOFTWARE\Classes\inot\shell\open\command"
        $fullGenapiKeyPath = $fullGenapiKeyPath.Replace("HKEY_USERS", "HKU:")
        
        $valueUrlPro = (Get-ItemProperty -Path $fullGenapiKeyPath -ErrorAction SilentlyContinue).'(default)'
        if($null -ne $valueUrlPro)
        {
            $valueUrlPro = $valueUrlPro.Replace('"', '')
            $valueUrlPro = $valueUrlPro.Replace(' %1', '')
            $inotPath = $valueUrlPro.Replace('GenApi.iNot.Client.UrlProtocolLauncher.exe', '')

            $configFilePath = Join-Path -Path $inotPath -ChildPath 'GenApi.iNot.Client.exe.config'
            Write-Host 'configFilePath=' $configFilePath
            
            Write-Host 'Before' (Get-Content $configFilePath)
            
            (Get-Content $configFilePath) -Replace 'https://ws.credoc.be/demandforms-1.00/', 'https://partner.fednot.be/fednot/partner/demand-forms-api/itp/v1' | Set-Content $configFilePath            
            
            Write-Host 'After' (Get-Content $configFilePath)
        }
    }

}
catch
{
    Write-Host $_
    exit 0 
}