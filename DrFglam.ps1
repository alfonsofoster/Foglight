<#
.SYNOPSIS
  Quick Audit of Fglam requirements for Foglight for Databases Cartridge.
.DESCRIPTION
  Script will check for Memory and CPU reservation, Antivirus Installation, FglAM permissions, 
  Windows Firewall activation, Port Listening, Winrm and WMI services, etc.
.PARAMETER < -results >
  Send this parameter if you will like to receive this Information in a txt file.
.INPUTS
  None
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         Alfonso Foster
  Creation Date:  15/Feb/2018
  Purpose/Change: Initial script development
  
.EXAMPLE
  Open a Powershell Windows "As Administrator", locate the Script and execute it.
#>

#---------------------------------------------------------[Initialisations]-------------------------------------------------------

$path = "C:\Program Files\VMware\VMware Tools\"  #Path where VMware tools are Installed.
$program = 'Microsoft Visual C++ 2010  x64' #Correct Display Name  of the MS VC 2010.
$hypervisors = "VMware" , "Virtual Machine"  #Hypervisors Model names.

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#Function only to check if a Directory exists
function Exists-Dir($path) { 
     if ([IO.Directory]::Exists($path)) { return $true; } 
    else { return $false; } 
} 

#Function to check Memory and CPU in a Hyper-V VM
Function Check-HyperV(){
Write-Host ("Hypervisor: Hyper-V `n") -ForegroundColor Yellow
}

#Check if VMware Tools is Installed and see if the VM has Memory and CPU reserved 
function Vmware-Check() {
if (Exists-Dir($path)) { 
    Write-Host ("Hypervisor: VMware `n")  -ForegroundColor Yellow
    $res_cpu = ((& "C:\Program Files\VMware\VMware Tools\vmwaretoolboxcmd.exe" stat cpures).Trim(" MHz")) #Getting the reserved CPU of a VMware VM
	$cpu_value = [int]$res_cpu
    if($cpu_value -gt 0){ Write-Host ("CPU reserved is: " + $res_cpu + " MHz `n") -ForegroundColor Green }
    else { Write-Host ("CPU is NOT Reserved") -ForegroundColor Red  }
    $res_mem = ((& "C:\Program Files\VMware\VMware Tools\vmwaretoolboxcmd.exe" stat memres).Trim(" MB")) #Getting the reserved Memory of a VMware VM
    $mem_value = [int]$res_mem
    if($mem_value -gt 0){ Write-Host ("Memory reserved is: " + $res_mem + " MB `n") -ForegroundColor Green }
    else { Write-Host ("Memory is NOT Reserved`n") -ForegroundColor Red }
    } 
else { Write-Host("VMware Tools is not Installed`n") -ForegroundColor Red } 
}

#Function for Check Visual C++ 2010
function Visualc-Check() {
$vc_installed = (Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" }).Length -gt 0;
if($vc_installed) { Write-Host ("Microsoft Visual C++ 2010 is Installed`n") -ForegroundColor Green }
else { Write-Host ("Microsoft Visual C++ 2010 is NOT Installed`n") -ForegroundColor Red }
}

#Function that check the server type
function ServerType-Check(){
$server_model = (Get-WmiObject -Class Win32_ComputerSystem).Model 
if($hypervisors | ?{$server_model -like "*$_*"}){
    Write-Host("This Host is a Virtual Machine.`n") -ForegroundColor Magenta
    if($server_model -like "VMware*") { Vmware-Check }
    else { Check-HyperV }
}
else { Write-Host("This Host is a Physical Machine.`n") -ForegroundColor Magenta }
} 

#Function that check if there is any Antivirus running in the server
function AV-Check(){
(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName| ForEach-Object {
    If($_ -match "End point" -or $_ -match "Antivirus" -or $_ -match "Malware") 
    { $av_found = $_ }
}
if($av_found) { Write-Host("This is an Antivirus? ---> " + $av_found) -ForegroundColor Red }
else { Write-Host("No Antivirus Software has been found.`n") -ForegroundColor Green }
}

#Check where the agent manager is installed and then looking for the old logs
function DeleteOld-Logs(){
$s = (Get-WmiObject win32_service | ?{$_.Name -like '*Agent Manager*'}).PathName.split('""')[1] #Removing the " of the path 
$fglam_path_external = $s.Substring(0, $s.lastIndexOf('bin')) #removing the "bin\fglam.exe" --manager-start-service" from the path
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
    } 
} 


}
#Remove-Item $old_folder -Recurse -Force 
}


Clear-Host # function that removes all text from the current display.
ServerType-Check #Calling Function to check the Type of the Server.
Visualc-Check #Calling the Function to check if Visual C++ 2010 is installed.
AV-Check #Calling the Function to check if there is any AV running in the server. 
DeleteOld-Logs #Check if there is any folder to delete thos old logs
