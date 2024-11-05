#TODO create functionality to subnet based on desired number of addresses per network
#TODO use the output to create new DHCP scopes in windows server

function Subnet-ByNetworkCount24{
    param([array]$splitNetMask,[int]$desiredNetworkCount,[int]$importantOctet)
    $addedBits = 0 
    while ($desiredNetworkCount -gt [Math]::Pow(2,$addedBits)){
        $addedBits++
    }
    $cleanIP = $splitNetMask[0]
    $ListOfSubnets = @()

    if ($importantOctet -eq "3"){
        $octet = @("","","","")
        $delimiter = 0
        for ($i = 0; $i -lt $splitNetMask[0].Length; $i++){
            if ($splitNetMask[0][$i] -eq "."){
                $delimiter++
            }
            else{
                $octet[$delimiter]+= $splitNetMask[0][$i]
            }
        }

        $newNetMask = $addedBits+[int]$splitNetMask[1]
        $addressCount = [Math]::Pow(2,8-$addedBits)
        write-host "Your subnet ID's and masks (in CIDR notation) are listed below, each subnet will contain " $addressCount " total addresses (only " ($addressCount - 2) " are useable)"
        for ($i = 0; $i -lt 255; $i += ([Math]::Pow(2,8-$addedBits))){
           # write-Host $octet[0]'.'$octet[1]'.'$octet[2]'.'$i'/'$newNetMask
            $temp = $octet[0] + '.' + $octet[1] + '.' + $octet[2] + '.' + [string]$i
            $ListOfSubnets += $temp

        }
        for($i = 0; $i -lt $ListOfSubnets.Length; $i++){
            write-host $ListOfSubnets[$i]'/'$newNetMask
        }
    }

    if ($importantOctet -eq "2"){
        $octet = @("","","","")
        $delimiter = 0
        for ($i = 0; $i -lt $splitNetMask[0].Length; $i++){
            if ($splitNetMask[0][$i] -eq "."){
                $delimiter++
            }
            else{
                $octet[$delimiter]+= $splitNetMask[0][$i]
            }
        }

        $newNetMask = $addedBits+[int]$splitNetMask[1]
        $addressCount = [Math]::Pow(2,8-$addedBits)*256
        write-host "Your subnet ID's and masks (in CIDR notation) are listed below, each subnet will contain " $addressCount " total addresses (only " ($addressCount - 2) " are useable)"
        for ($i = 0; $i -lt 255; $i += ([Math]::Pow(2,8-$addedBits))){
           # write-Host $octet[0]'.'$octet[1]'.'$octet[2]'.'$i'/'$newNetMask
            $temp = $octet[0] + '.' + $octet[1] + '.' + [string]$i + '.' + $octet[3]
            $ListOfSubnets += $temp

        }
        for($i = 0; $i -lt $ListOfSubnets.Length; $i++){
            write-host $ListOfSubnets[$i]'/'$newNetMask
        }
    }

    if ($importantOctet -eq "1"){
        $octet = @("","","","")
        $delimiter = 0
        for ($i = 0; $i -lt $splitNetMask[0].Length; $i++){
            if ($splitNetMask[0][$i] -eq "."){
                $delimiter++
            }
            else{
                $octet[$delimiter]+= $splitNetMask[0][$i]
            }
        }

        $newNetMask = $addedBits+[int]$splitNetMask[1]
        $addressCount = [Math]::Pow(2,8-$addedBits)*[Math]::Pow(256, 2)
        write-host "Your subnet ID's and masks (in CIDR notation) are listed below, each subnet will contain " $addressCount " total addresses (only " ($addressCount - 2) " are useable)"
        for ($i = 0; $i -lt 255; $i += ([Math]::Pow(2,8-$addedBits))){
           # write-Host $octet[0]'.'$octet[1]'.'$octet[2]'.'$i'/'$newNetMask
            $temp = $octet[0] + '.' + [string]$i + '.' + $octet[2] + '.' + $octet[3]
            $ListOfSubnets += $temp

        }
        for($i = 0; $i -lt $ListOfSubnets.Length; $i++){
            write-host $ListOfSubnets[$i]'/'$newNetMask
        }
    }
    

    $makeScope = read-host "Would you like to use the created subnets to make a new scope? (1=yes, 0=no)"   
    $makeScope = [int]$makeScope
    if ($makeScope -eq 0 ){
        exit
    }
    elseif ($makeScope -eq 1){
        Offer-DHCPv4Scope -subnetList $ListOfSubnets -CIDRMask $newNetMask
    }
    else{
        write-host "[PEBCAK ERROR] exiting program - seek help from administrator and try again"
    }
    
    
    
    
    
}

function Offer-DHCPv4Scope{
    param([array]$subnetList, [int]$CIDRMask)
    
    $SubnetMask = ''
    $FilledOctets = [Math]::truncate($CIDRMask/8)
    for ($i = 0; $i -lt $FilledOctets; $i++){
        $SubnetMask += '255.'
    }
    $totallyMeaningfulVariable = $FilledOctets+1
    $NoteworthyOctet = 0
    for ($i = 0; $i -lt 255; $i += [Math]::Pow(2,(8-($CIDRMask % 8)))){
        $NoteWorthyOctet = $i
    }
    $SubnetMask += [string]$NoteWorthyOctet
    $FilledOctets++
    if ($FilledOctets -lt 4){
        for ($i = $FilledOctets; $i -lt 4; $i++){
            $SubnetMask += '.0'
        }
    }
    $numberOfScopes = Read-Host "how many scopes would you like to create"
    if ($numberOfScopes -gt $subnetList.Length){
        write-host "You're a dumbass, go get your boss and try again"
        exit
    }
    write-host $numberOfScopes
    for($i = 0; $i -lt $numberOfScopes; $i++){
        write-host "creating scope number" $i
        $scopeName = Read-Host "what would you like to name this scope?"
        $startScopeRange = $subnetList[$i]
        $startScopeRangeList = $startScopeRange.split('.')
        $startScopeRangeList[$totallyMeaningfulVariable - 1] = [int]$startScopeRangeList[$totallyMeaningfulVariable - 1] +1
        $startScopeRange = ""
        if($i+1 -lt $subnetList.Length){
            $endScopeRange = $subnetList[$i+1]
            $endScopeRangeList = $endScopeRange.split('.')
            $endScopeRangeList[$totallyMeaningfulVariable -1] = [int]$endScopeRangeList[$totallyMeaningfulVariable - 1] -2
            $endScopeRange = ""
        }
        else{
            write-host 'you need to write this edge case still'
        }
        for ($j = 0; $j -lt 4; $j++){
            $startScopeRange += $startScopeRangeList[$j]
            $endScopeRange += $endScopeRangeList[$j] 
            if ($j -lt 3){
                $startScopeRange += '.'
                $endScopeRange += '.'
            }
        }
        
        write-host  'Add-DhcpServerv4Scope -Name' $scopeName '-StartRange' $startScopeRange '-EndRange' $endScopeRange '-SubnetMask' $SubnetMask
    }
}
$CurrentNetwork = Read-Host "please enter the current subnetID and subnet mask in CIDR notation`n(for example 192.168.0.0/24)"
$splitNetMask = $CurrentNetwork -split "/"
$importantOctet = 0
if ($splitNetMask[1] -eq "24"){
    $importantOctet = 3
}
elseif ($splitNetMask[1] -eq "16"){
    $importantOctet = 2
}
elseif ($splitNetMask[1] -eq "8"){
    $importantOctet = 1
}
else{
    write-host "error please try again"
    exit
}


$desiredNetworkCountRaw = Read-Host "please enter the number of networks you would like total when subnetting is completed"
$desiredNetworkCount = [int]$desiredNetworkCountRaw
Subnet-ByNetworkCount24 -splitNetMask $splitNetMask -desiredNetworkCount $desiredNetworkCount -importantOctet $importantOctet
