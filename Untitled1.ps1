
(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName| ForEach-Object {
    If($_ -match "End point" -or $_ -match "Antivirus") {
    Write-Host $($_) ; 
    }
}

$av_key = "End point" , "Antivirus" , "TeamViewer"
(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName| ForEach-Object {
    If($_ -match $av_key ) {
    #Write-Host $($_)
    }  
} | Foreach {$Matches[0]}
Write-Host($Matches)



