﻿function Exists-Dir($path) { 
     if ([IO.Directory]::Exists($path)) { return $true; } 
    else { return $false; } 
} 

Clear-Host
#Check if fglam is external

function External-Fglam() {
$s = (Get-WmiObject win32_service | ?{$_.Name -like '*Agent Manager*'}).PathName #Removing the " of the path 
if ($s){
$s = $s.split('""')[1]
$fglam_path_external = $s.Substring(0, $s.lastIndexOf('bin')) #removing the "bin\fglam.exe" --manager-start-service" from the path
 Write-Host("Agent Manager has been installed in ") -ForegroundColor Green -NoNewline; Write-Host($fglam_path + "`n") }
else { 
Write-Host("No external Fglam running as a Service here!... Checking if its Embeded... `n") -ForegroundColor Yellow 
Embedded-Fglam
}

$fglam_logs_sqlserver = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_SQL_Server"
$fglam_logs_oracle = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_Oracle"
$fglam_logs_db2 = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_DB2"
$fglam_logs_hostagents = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\HostAgents"

$fglam_logs = $fglam_logs_sqlserver , $fglam_logs_oracle , $fglam_logs_db2 + $fglam_logs_hostagents

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
}


function Embedded-Fglam () {
$s = (Get-WmiObject win32_service | ?{$_.Name -like 'Foglight'}).PathName
$s = $s.split('""')[1]
$s = $s.Substring(0, $s.lastIndexOf('bin'))
$fglam_config_file = $s + "\config\server.config" 

$is_embedded = (Get-Content $fglam_config_file | select-string 'server.fglam.embedded = "true";' -SimpleMatch)
if($is_embedded) {
Write-Host("Fglam Embedded is Enable `n") -ForegroundColor Green 
$fglam_logs_sqlserver = $s + "fglam\state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_SQL_Server"
$fglam_logs_oracle = $s + "fglam\state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_Oracle"
$fglam_logs_db2 = $s + "fglam\state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_DB2"
$fglam_logs_hostagents = $s + "fglam\state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\HostAgents"

$fglam_logs = $fglam_logs_sqlserver , $fglam_logs_oracle , $fglam_logs_db2 + $fglam_logs_hostagents

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

}
}



External-Fglam

#if($fglam_path_embedded){
#Write-Host($fglam_path_embedded) 
#Get-Content .\server.config | select-string 'server.fglam.embedded = "true";' -SimpleMatch
#}
#else { Write-Host("Foglight service not Found. This could be an Fglam? ") }




