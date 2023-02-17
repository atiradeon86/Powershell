Start-Transcript

Clear-Host

#Settings
$ad_domain = "bryan.local"
$ErrorActionPreference= "silentlycontinue"

Write-Host "With this script you can add all Groups Membership from Reference user to Target user ...`r`n"
Write-Host "Current-Domain: $ad_domain `r`n"

#Get Reference User Name
$ref_user= Read-Host -Prompt "Please enter the Reference Username"

Write-Host "Reference User:" $ref_user"`r`n" -ForegroundColor Green

#Check User Exist?
$ad_user = Get-Aduser -Server $ad_domain -Identity $ref_user
if (-not ($ad_user)) {
    echo "User ($ref_user) Does Not Exist on Domain: $ad_domain ... Please try again ..."
} else {

#Get-Group Memberships
[Array]$ref_user_groups = Get-ADPrincipalGroupMembership -Server $ad_domain -Identity $ref_user | Select-Object -ExpandProperty Name

Write-Host "Groups:`n"
Write-Host ($ref_user_groups -Join "`r`n")

Write-Host "`n"
$target_user = Read-Host -Prompt "Please enter the Target Username"
Write-Host "Target User:" $target_user"`r`n" -ForegroundColor Red

#Check -> Target User Exist on This Domain?
$check = Get-Aduser -Server $ad_domain -Identity $target_user | Select-Object -ExpandProperty Name 

if (-not ($check)) {
    echo "User ($target_user) Does Not Exist on Domain: $ad_domain ... Please try again ..."
} else {

    $title    = 'Confirm'
    $question = 'Do you want to continue?'
    $choices  = '&Yes', '&No'
    
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'Your choice is Yes.'
        foreach ($Groups in $ref_user_groups) {            
            Add-ADPrincipalGroupMembership -Identity $target_user -Server $ad_domain -MemberOf $Groups     
        }
    } else {
        Write-Host "Bye ..."
        exit
    }

    #Show some debug info
    $info = Get-Aduser -Server $ad_domain -Identity $target_user | Select *
    echo $info
    [array]$target_user_groups = Get-ADPrincipalGroupMembership -Server $ad_domain -Identity $target_user | Select-Object -ExpandProperty Name
    Write-Host "Group Memberships:`r`n" -ForegroundColor Green
    Write-Host ($target_user_groups -Join "`r`n")
    
    }
}

Stop-Transcript
