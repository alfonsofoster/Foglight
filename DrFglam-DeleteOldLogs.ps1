function Exists-Dir($path) { 
     if ([IO.Directory]::Exists($path)) { return $true; } 
    else { return $false; } 
} 

Clear-Host


$s = (Get-WmiObject win32_service | ?{$_.Name -like '*Agent Manager*'}).PathName.split('""')[1] #Removing the " of the path 
$fglam_path = $s.Substring(0, $s.lastIndexOf('bin')) #removing the "bin\fglam.exe" --manager-start-service" from the path
Write-Host("Agent Manager has been installed in ") -ForegroundColor Green -NoNewline; Write-Host($fglam_path + "`n")

$fglam_logs_sqlserver = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_SQL_Server"
$fglam_logs_oracle = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_Oracle"
$fglam_logs_db2 = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_DB2"
$fglam_logs_hostagents = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\HostAgents"

$fglam_logs = $fglam_logs_sqlserver , $fglam_logs_oracle , $fglam_logs_db2

ForEach($log in $fglam_logs){

if(Exists-Dir($log)) {
    if(Exists-Dir($log)) {
    Write-Host("Fglam_agents: ") -ForegroundColor Green -NoNewline ; Write-Host($log + "`n") 

    $old_folder = (gci "$log" | ?{$_.PsIsContainer}| sort LastWriteTime -desc | select -Skip 1).Name #Getting the Name
    
    $deleting = $old_folder | Format-List | Out-String|% {$_}  #Printing the folder that we are going to delete
    if($deleting) { 
    Write-Host("Removing Folder:") -ForegroundColor Magenta
        Write-Host($deleting) }
        else { Write-Host("Nothing to Remove `n") -ForegroundColor Magenta }
    $current_log_folder = (gci "$log" | ?{$_.PsIsContainer} | sort @{Expression={$_.LastWriteTime}; Ascending=$false}| select -first 1).Name #we selected the first folder 
    Write-Host("Keeping Folder (Current Cartridge): ") -ForegroundColor Green -NoNewline; Write-Host($current_log_folder + "`n") -ForegroundColor Yellow
    } #En of IF for fglam logs path
} #End of IF for fglam root path
#End of Foreach

}
#Remove-Item $old_folder -Recurse -Force 



