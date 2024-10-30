#TODO create functionality to subnet based on desired number of addresses per network
#TODO use the output to create new DHCP scopes in windows server

function Subnet-ByNetworkCount24{
    param([array]$splitNetMask,[int]$desiredNetworkCount,[int]$importantOctet)
    $addedBits = 0 
    while ($desiredNetworkCount -gt [Math]::Pow(2,$addedBits)){
        $addedBits++
    }
    $cleanIP = $splitNetMask[0]
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
            write-Host $octet[0]"."$octet[1]"."$octet[2]"."$i"/"$newNetMask
        }
    }
    elseif ($importantOctet -eq "2"){
        $octet = @("","","","")
        $delimiter = 0
        for ($i = 0; $i -lt $cleanIP.Length; $i++){
            if ($cleanIP[$i] -eq "."){
                $delimiter++
            }
            else{
                $octet[$delimiter]+= $cleanIP[$i]
            }
        }
        for ($i = 0; $i -lt $octet.Length-1; $i++){
            $octet[$i] += " ."
        }

        $newNetMask = $addedBits+[int]$splitNetMask[1]
        $addressCount = [Math]::Pow(2,8-$addedBits)*256
        write-host "Your subnet ID's and masks (in CIDR notation) are listed below, each subnet will contain " $addressCount " total addresses (only " ($addressCount - 2) " are useable)"
        for ($i = 0; $i -lt 255; $i += ([Math]::Pow(2,8-$addedBits))){
            $octet[2] = [string]$i 
            $octet[2] += " ."
            write-host $octet` `/$newNetMask
        }
        
    }
    elseif ($importantOctet -eq "1"){
        $octet = @("","","","")
        $delimiter = 0
        for ($i = 0; $i -lt $cleanIP.Length; $i++){
            if ($cleanIP[$i] -eq "."){
                $delimiter++
            }
            else{
                $octet[$delimiter]+= $cleanIP[$i]
            }
        }
        for ($i = 0; $i -lt $octet.Length-1; $i++){
            $octet[$i] += " ."
        }

        $newNetMask = $addedBits+[int]$splitNetMask[1]
        $addressCount = [Math]::Pow(2,8-$addedBits)*[Math]::Pow(256,2)
        write-host "Your subnet ID's and masks (in CIDR notation) are listed below, each subnet will contain " $addressCount " total addresses (only " ($addressCount - 2) " are useable)"
        for ($i = 0; $i -lt 255; $i += ([Math]::Pow(2,8-$addedBits))){
            $octet[1] = [string]$i 
            $octet[1] += " ."
            write-host $octet` `/$newNetMask
        }
        
    }
}
function Subnet-ByAddressCount{
    param($splitNetMask, $desiredAddressCount)
    


}
write-host "Warning this program currently only works for /24 networks`nLater as time allows I will expand functionality"
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
