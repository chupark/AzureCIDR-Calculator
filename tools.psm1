## https://stackoverflow.com/questions/31409009/how-to-have-a-powershell-function-return-a-table

Function MakeTable ($TableName, $ColumnArray) {
    $table = New-Object System.Data.DataTable("$TableName")
    foreach($Col in $ColumnArray)
    {
        $MCol = New-Object System.Data.DataColumn $Col;
        $table.Columns.Add($MCol)

      }
    return , $table
}

# by me cwpark!

function findVMNameWithNICName ([String]$nicName, $inputVMS) {
    foreach ($inputVm in $inputVMS) {
        foreach ($nic in $inputVm.NetworkProfile.NetworkInterfaces.Id) {
            $aa = $nic -match "/Microsoft.Network/networkInterfaces/(?<nicName>.+)"
            if ($Matches.nicName.ToString() -eq $nicName) {
                return $inputVm.Name
            }
        }
    }
}

function createResourceLock() {
    param (
        [PSCustomObject]$programEnv,
        [PSCustomObject]$resourceList
    )
    foreach ($resource in $resourceList) {
        New-AzResourceLock -LockLevel CanNotDelete `
                           -LockName $programEnv.lock.name `
                           -ResourceName $resource.RowKey `
                           -ResourceType $resource.Type `
                           -ResourceGroupName $resource.resourceGroup `
                           -LockNotes $programEnv.lock.note `
                           -Force
    }
}

function removeRemoveLock() {
    param (
        [PSCustomObject]$programEnv,
        [PSCustomObject]$resourceList
    )
    foreach ($resource in $resourceList) {
        Remove-AzResourceLock -LockName $programEnv.lock.name `
                              -ResourceName $resource.RowKey `
                              -ResourceType $resource.Type `
                              -ResourceGroupName $resource.resourceGroup `
                              -Force
    }
}