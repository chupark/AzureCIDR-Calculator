Import-Module -Name D:\PowerShell\AzureCIDR-Calculator\cidr.psm1 -Force
Import-Module -Name D:\PowerShell\AzureCIDR-Calculator\tools.psm1 -Force
$vnets = Get-AzVirtualNetwork
$vms = Get-AzVM
$nics = Get-AzNetworkInterface
$lbs = Get-AzLoadBalancer

$col = @("subnet", "prefix", "resourceKind", "ip", "associate_to")
$ipTable = MakeTable -TableName "ipTable" -ColumnArray $col
foreach ($vnet in $vnets) {
    foreach ($subnets in $vnet.Subnets) {
        foreach ($subnet in $subnets) {
            $cidr = getCidrCalculator
            $cidr.setCidr($subnet.AddressPrefix)
            $cidr.calculationCidr()
            foreach ($cid in $cidr.cidrRange) {
                $row = $ipTable.NewRow()
                $row.ip = $cid
                $row.prefix = [String]$subnet.AddressPrefix
                $row.subnet = $subnet.Name
                $ipTable.Rows.Add($row)
            }
        }
    }
}

# $ipTable | Where-Object {$_.subnet -eq "D-IFT1-SN"}
# $azx = $nics | Sort-Object $nics.IpConfigurations.Subnet.Id
$cnt = 1;
foreach ($nic in $nics) {
    $Matches = $null
    $null = $nic.VirtualMachine.Id -match "Microsoft.Compute/virtualMachines/(?<vmName>.+)"
    $vmName = $Matches.vmName
    foreach ($nicIP in $nic.IpConfigurations) {
        $Matches = $null
        ## 서브넷을 먼저 찾음
        $null = $nicIP.Subnet.Id -match "Microsoft.Network/virtualNetworks/[a-zA-Z0-9\-]{0,20}/subnets/(?<subnetName>.+)"
        ## 불러온 IP 목록 중 NIC의 IP와 같은 row에 데이터 저장
        $loadedSubnet = $ipTable | Where-Object {$_.subnet -eq $Matches.subnetName} | Where-Object {$_.ip -eq $nicIP.PrivateIpAddress}
        ## VM Name이 있을 경우에만 작업
        if($vmName) {
            $loadedSubnet.resourceKind = "NetworkInterface"
            $loadedSubnet.associate_to = $vmName
        }
    }
    Write-Host $cnt / $nics.Count
    $cnt ++
}

$cnt = 1
foreach ($lb in $lbs) {
    $lbName = $lb.Name
    foreach ($lbfront in $lb.FrontendIpConfigurations) {
        $Matches = $null
        ## 서브넷을 먼저 찾음
        $null = $lbfront.Subnet.Id -match "Microsoft.Network/virtualNetworks/[a-zA-Z0-9\-]{0,20}/subnets/(?<subnetName>.+)"
        ## 불러온 IP 목록 중 LB의 IP와 같은 row에 데이터 저장
        $loadedSubnet = $ipTable | Where-Object {$_.subnet -eq $Matches.subnetName} | Where-Object {$_.ip -eq $lbfront.PrivateIpAddress}
        ## Public LB가 섞여있으므로
        if($lbfront.PrivateIpAddress) {
            $loadedSubnet.resourceKind = "Internal_LoadBalancer"
            $loadedSubnet.associate_to = $lbName
        }
    }
    Write-Host $cnt / $lbs.Count
    $cnt ++
}

$ipTable | Export-Csv -Path "D:\PowerShell\AzureCIDR-Calculator\ipTable.csv"