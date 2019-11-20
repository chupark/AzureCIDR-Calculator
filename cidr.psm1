function getCidrCalculator() {
    return [cidr]::new()
}

class cidr {
    [Array]$cidrRange
    [String]$cidr
    [String]$startIP
    [String]$endIP

    [Int32]getTotalHost() {
        return $this.cidrRange.Length
    }

    [Array]getAllHostIP() {
        return $this.cidrRange
    }

    [String]getStartIP() {
        return $this.startIP
    }

    [String]getEndIP() {
        return $this.endIP
    }

    [Int32]getHostCount() {
        $cidrSplit = $this.cidr.Split("/")
        return [math]::Pow(2, 32 - $cidrSplit[1])
    }

    setCidr([String]$cidr) {
        $this.cidr = $cidr
    }

    setStartToEndIP() {
        $cidrSplit = $this.cidr.Split("/")
        $ip = $cidrSplit[0].Split(".")
        [Int32]$range = $cidrSplit[1]
        [Int32[]]$firstIP = $ip
        if ($range -le 32 -and $range -ge 24) {
            $ipCount = [math]::Pow(2, 32-$range)
            $firstIP[$firstIP.Length - 1] = $ip[$ip.Length - 1] - ($ip[$ip.Length - 1] % $ipCount)
            $this.startIP = $firstIP -join "."
            
            $firstIP[$firstIP.Length - 1] = $ip[$ip.Length - 1] + $ipCount - 1
            $this.endIP = $firstIP -join "."
        } elseif ($range -le 23 -and $range -ge 16) {
            $ipCount = [math]::Pow(2, 24-$range)
            $firstIP[$firstIP.Length - 2] = $ip[$ip.Length - 2] - ($ip[$ip.Length - 2] % $ipCount)
            $firstIP[$firstIP.Length - 1] = 0
            $this.startIP = $firstIP -join "."

            $firstIP[$firstIP.Length - 2] = $firstIP[$firstIP.Length - 2] + $ipCount - 1
            $firstIP[$firstIP.Length - 1] = 255
            $this.endIP = $firstIP -join "."
        } elseif ($range -le 15 -and $range -ge 8) {
            $ipCount = [math]::Pow(2, 16-$range)
            $firstIP[$firstIP.Length - 3] = $ip[$ip.Length - 3] - ($ip[$ip.Length - 3] % $ipCount)
            $firstIP[$firstIP.Length - 2] = 0
            $firstIP[$firstIP.Length - 1] = 0
            $this.startIP = $firstIP -join "."

            $firstIP[$firstIP.Length - 3] = $firstIP[$firstIP.Length - 3] + $ipCount - 1
            $firstIP[$firstIP.Length - 2] = 255
            $firstIP[$firstIP.Length - 1] = 255
            $this.endIP = $firstIP -join "."
        } elseif ($range -le 7 -and $range -ge 0) {
            $ipCount = [math]::Pow(2, 8-$range)
            $firstIP[$firstIP.Length - 4] = $ip[$ip.Length - 4] - ($ip[$ip.Length - 4] % $ipCount)
            $firstIP[$firstIP.Length - 3] = 0
            $firstIP[$firstIP.Length - 2] = 0
            $firstIP[$firstIP.Length - 1] = 0
            $this.startIP = $firstIP -join "."
            
            $firstIP[$firstIP.Length - 4] = $firstIP[$firstIP.Length - 4] + $ipCount - 1
            $firstIP[$firstIP.Length - 3] = 255
            $firstIP[$firstIP.Length - 2] = 255
            $firstIP[$firstIP.Length - 1] = 255
            $this.endIP = $firstIP -join "."
        } else {
            Write-Host out of range
        }
    }

    calculationCidr() {
        $this.cidrRange = $null
        $cidrSplit = $this.cidr.Split("/")
        $ip = $cidrSplit[0].Split(".")
        $range = $cidrSplit[1]
        [Int32[]]$firstIP = $ip
        if ($range -ge 24 -and $range -le 32) {
            $ipCount = [math]::Pow(2, 32-$range)
            $firstIP[$firstIP.Length - 1] = $ip[$ip.Length - 1] - ($ip[$ip.Length - 1] % $ipCount)
            foreach($i in $firstIP[$firstIP.Length - 1]..($firstIP[$firstIP.Length - 1] + $ipCount - 1)) {
                $firstIP[$firstIP.Length - 1] = $i
                $this.cidrRange += $firstIP -join "."
            }
        } elseif ($range -ge 16 -and $range -le 23) {
            $ipCount = [math]::Pow(2, 24-$range)
            $firstIP[$firstIP.Length - 2] = $ip[$ip.Length - 2] - ($ip[$ip.Length - 2] % $ipCount)
            $firstIP[$firstIP.Length - 1] = 0
            foreach($i in $firstIP[$firstIP.Length - 2]..($firstIP[$firstIP.Length - 2] + $ipCount - 1)) {
                $firstIP[$firstIP.Length - 2] = $i
                foreach($j in 0..255) {
                    $firstIP[$firstIP.Length - 1] = $j
                    $this.cidrRange += $firstIP -join "."
                }
            }
        } elseif ($range -ge 8 -and $range -le 15) {
            $ipCount = [math]::Pow(2, 16-$range)
            $firstIP[$firstIP.Length - 3] = $ip[$ip.Length - 3] - ($ip[$ip.Length - 3] % $ipCount)
            $firstIP[$firstIP.Length - 2] = 0
            $firstIP[$firstIP.Length - 1] = 0
            foreach($i in $firstIP[$firstIP.Length - 3]..($firstIP[$firstIP.Length - 3] + $ipCount - 1)) {
                $firstIP[$firstIP.Length - 3] = $i
                foreach($j in 0..255) {
                    $firstIP[$firstIP.Length - 2] = $j
                    foreach($k in 0..255) {
                        $firstIP[$firstIP.Length - 1] = $k
                        $this.cidrRange += $firstIP -join "."
                    }
                }
            }
        } elseif ($range -ge 0 -and $range -le 7) {
            $ipCount = [math]::Pow(2, 8-$range)
            $firstIP[$firstIP.Length - 4] = $ip[$ip.Length - 4] - ($ip[$ip.Length - 4] % $ipCount)
            $firstIP[$firstIP.Length - 3] = 0
            $firstIP[$firstIP.Length - 2] = 0
            $firstIP[$firstIP.Length - 1] = 0
            foreach($i in $firstIP[$firstIP.Length - 4]..($firstIP[$firstIP.Length - 4] + $ipCount - 1)) {
                $firstIP[$firstIP.Length - 4] = $i
                foreach($j in 0..255) {
                    $firstIP[$firstIP.Length - 3] = $j
                    foreach($k in 0..255) {
                        $firstIP[$firstIP.Length - 2] = $k
                        foreach($l in 0..255) {
                            $firstIP[$firstIP.Length - 1] = $l
                            $this.cidrRange += $firstIP -join "."
                        }
                    }
                }
            }
        } else {
            Write-Host out of range
        }
    }
}