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
     if ([IO.Directory]::Exists($path)) { 
     return $true; 
     } 
    else { 
    return $false; 
    } 
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
            if($cpu_value -gt 0){ 
            Write-Host ("CPU reserved is: " + $res_cpu + " MHz `n") -ForegroundColor Green 
            }
            else { 
            Write-Host ("CPU is NOT Reserved") -ForegroundColor Red  
            }
            $res_mem = ((& "C:\Program Files\VMware\VMware Tools\vmwaretoolboxcmd.exe" stat memres).Trim(" MB")) #Getting the reserved Memory of a VMware VM
            $mem_value = [int]$res_mem
                if($mem_value -gt 0){ 
                Write-Host ("Memory reserved is: " + $res_mem + " MB `n") -ForegroundColor Green 
                }
                else { 
                Write-Host ("Memory is NOT Reserved`n") -ForegroundColor Red 
                }
    } 
    else { 
    Write-Host("VMware Tools is not Installed`n") -ForegroundColor Red 
    } 
}

#Function for Check Visual C++ 2010
function Visualc-Check() {
    $vc_installed = (Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" }).Length -gt 0;
        if($vc_installed) { 
        Write-Host ("Microsoft Visual C++ 2010 is Installed`n") -ForegroundColor Green 
        }
        else { 
        Write-Host ("Microsoft Visual C++ 2010 is NOT Installed`n") -ForegroundColor Red
        }
}

#Function that check the server type
function ServerType-Check(){
    $server_model = (Get-WmiObject -Class Win32_ComputerSystem).Model 
        if($hypervisors | ?{$server_model -like "*$_*"}) {
        Write-Host("This Host is a Virtual Machine.`n") -ForegroundColor Magenta
            if($server_model -like "VMware*") { 
            Vmware-Check 
            }
            else { 
            Check-HyperV
            }
        }
        else { 
        Write-Host("This Host is a Physical Machine.`n") -ForegroundColor Magenta 
        }
} 

#Function that check if there is any Antivirus running in the server
function AV-Check(){
    (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName| 
    ForEach-Object { If($_ -match "End point" -or $_ -match "Antivirus" -or $_ -match "Malware") { 
    $av_found = $_ 
    }
    }
    if($av_found) { 
    Write-Host("This is an Antivirus? ---> " + $av_found) -ForegroundColor Red 
    }
    else { 
    Write-Host("No Antivirus Software has been found.`n") -ForegroundColor Green 
    }
}


Clear-Host # function that removes all text from the current display.
ServerType-Check #Calling Function to check the Type of the Server.
Visualc-Check #Calling the Function to check if Visual C++ 2010 is installed.
AV-Check #Calling the Function to check if there is any AV running in the server. 



#Remove-Item $old_folder -Recurse -Force 