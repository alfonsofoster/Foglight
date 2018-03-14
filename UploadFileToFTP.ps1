
Add-PSSnapin -Name ktools.powershell.sftp

$sftpHost = "ftpamer.quest.com"

$port = "122"

$userName = "monitoringtech"

$userPassword = "!Quest4ever"

$files = "C:\file1.txt" #specify full path to  your files here

$sftp = Open-SFTPServer -serverAddress $sftpHost -userName $userName -userPassword $userPassword
foreach($file in $files){

$sftp.Put($file, "/monitoring/secure")
}

#Close the SFTP connection

$sftp.Close()