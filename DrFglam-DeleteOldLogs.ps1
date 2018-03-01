
<#
.SYNOPSIS
  Check old logs files of Foglight for Databases Cartridge.
.DESCRIPTION
  Script will check in Agent and Logs folders to see if there are being updating or not, and then delete the "old" one and keep the newest one.
.PARAMETER 
  No paremeter is required.
.INPUTS
  None
.OUTPUTS
  All the Information will be show in the Powershell window.
.NOTES
  Version:        1.0
  Author:         Alfonso Foster
  Creation Date:  28/Feb/2018
  Purpose/Change: Initial script development
  
.EXAMPLE
  Open a Powershell Windows "As Administrator", locate the Script and execute it.
#>


#Function that Validate if a Directory exists.
function Exists-Dir($path) { 
     if ([IO.Directory]::Exists($path)) { 
        return $true; 
        } 
    else { 
        return $false; 
        } 
} #End of Function Exists-Dir

#Function that return the Logs folders
Function Logs-Folders($fglam_path) {
    $fglam_logs_sqlserver = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_SQL_Server"
    $fglam_logs_oracle = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_Oracle"
    $fglam_logs_db2 = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\DB_DB2"
    $fglam_logs_hostagents = $fglam_path + "state\default\logs\fb8be857-fbcf-4747-973d-295a8570e581\HostAgents"
    $fglam_logs = $fglam_logs_sqlserver , $fglam_logs_oracle , $fglam_logs_db2 , $fglam_logs_hostagents
    return $fglam_logs;
}

Function Agents-Folders($fglam_path) {
    $fglam_agents_sqlserver = $fglam_path + "state\default\agents\fb8be857-fbcf-4747-973d-295a8570e581\DB_SQL_Server"
    $fglam_agents_oracle = $fglam_path + "state\default\agents\fb8be857-fbcf-4747-973d-295a8570e581\DB_Oracle"
    $fglam_agents_db2 = $fglam_path + "state\default\agents\fb8be857-fbcf-4747-973d-295a8570e581\DB_DB2"
    $fglam_agents_hostagents = $fglam_path + "state\default\agents\fb8be857-fbcf-4747-973d-295a8570e581\HostAgents"
    $fglam_agents = $fglam_lagents_sqlserver , $fglam_agents_oracle , $fglam_agents_db2 , $fglam_agents_hostagents
    return $fglam_agents;
}

Function CheckTo-Delete ($log){
  if(Exists-Dir($log)) {
        if(Exists-Dir($log)) {
            Write-Host("Fglam LOG Folder: ") -ForegroundColor Green -NoNewline ; Write-Host($log + "`n") 
            $old_folder = (gci "$log" | ?{$_.PsIsContainer}| sort LastWriteTime -desc | select -Skip 1).Name #Getting the NAME of all the current folders except the LastUpdated one.
            $deleting = $old_folder | Format-List | Out-String|% {$_}  #Printing the folder that we are going to delete
            if($deleting) { 
                Write-Host("Removing Folder:") -ForegroundColor Magenta
                Write-Host($deleting) 
            }
            else { 
            Write-Host("Nothing to Remove `n") -ForegroundColor Magenta 
            }
    $current_log_folder = (gci "$log" | ?{$_.PsIsContainer} | sort @{Expression={$_.LastWriteTime}; Ascending=$false}| select -first 1).Name #Obtaining the LastUpdated Folder Name 
    Write-Host("Keeping Folder (Current Cartridge): ") -ForegroundColor Green -NoNewline; Write-Host($current_log_folder + "`n") -ForegroundColor Yellow
        } 
    }
  }
 

#Function that Check for Logs of an External Agent Manager
function External-Fglam() {
    $paths = (Get-WmiObject win32_service | ?{$_.Name -like '*Agent Manager*'}).PathName 
    if ($paths){
        foreach($path_list in $paths) {  
            $path_list = $path_list.split('""')[1] #Removing the quote (") of All the FAglam path detected.
            $fglam_path = $path_list.Substring(0, $path_list.lastIndexOf('bin')) #Removing the "bin\fglam.exe --manager-start-service" from the path.
            Write-Host("Agent Manager has been installed in ") -ForegroundColor Green -NoNewline; 
            Write-Host($fglam_path + "`n") #Printing FAglam ROOT folder 
            $fglam_logs = Logs-Folders($fglam_path)
            ForEach($log in $fglam_logs){
              CheckTo-Delete ($log)
             }
             $fglam_agents = Agents-Folders($fglam_path)
             ForEach($agents in $fglam_agents){
                if(Exists-Dir($agents)) {
                    if(Exists-Dir($agents)) {
                        Write-Host("Fglam AGENTS Folder: ") -ForegroundColor Green -NoNewline ; Write-Host($agents + "`n") 
                        $old_folder = (gci "$agents" | ?{$_.PsIsContainer}| sort LastWriteTime -desc | select -Skip 1).Name #Getting the NAME of all the current folders except the LastUpdated one.
                        $deleting = $old_folder | Format-List | Out-String|% {$_}  #Printing the folder that we are going to delete
                        if($deleting) { 
                            Write-Host("Removing Folder:") -ForegroundColor Magenta
                            Write-Host($deleting) 
                        }
                        else { 
                        Write-Host("Nothing to Remove `n") -ForegroundColor Magenta 
                        }
            $current_log_folder = (gci "$log" | ?{$_.PsIsContainer} | sort @{Expression={$_.LastWriteTime}; Ascending=$false}| select -first 1).Name #Obtaining the LastUpdated Folder Name 
            Write-Host("Keeping Folder (Current Cartridge): ") -ForegroundColor Green -NoNewline; Write-Host($current_log_folder + "`n") -ForegroundColor Yellow
                    } 
                } 
             }
        } 
}
else { 
Write-Host("No external Fglam running as a Service here!... Checking if its Embedded... `n") -ForegroundColor Yellow 
Embedded-Fglam #Calling the Function to check if there is any Embedded FAglam
}
#Remove-Item $old_folder -Recurse -Force 
}


function Embedded-Fglam () {
    $path = Get-WmiObject win32_service | ?{$_.Name -like 'Foglight'}
    if($path) {
        $path_list = ($path.PathName.split('""')[1]) 
        $path_list = $path_list.Substring(0, $path_list.lastIndexOf('bin')) 
        $fglam_config_file = $path_list + "\config\server.config" 
        $is_embedded = (Get-Content $fglam_config_file | select-string 'server.fglam.embedded = "true";' -SimpleMatch)
            if($is_embedded) {
                Write-Host("Fglam Embedded is Enable `n") -ForegroundColor Green 
                Write-Host("Agent Manager ROOT folder is located at: ") -ForegroundColor Green -NoNewline; 
                $fglam_path = $path_list +"fglam\"
                Write-Host( $fglam_path + "`n")
                $fglam_logs = Logs-Folders($fglam_path)
                ForEach($log in $fglam_logs){
                    CheckTo-Delete ($log) 
                }
            }
    }
    else { 
    Write-Host("No Embedded Fglam Found either ...") -ForegroundColor Yellow 
    }
}

Clear-Host
External-Fglam








