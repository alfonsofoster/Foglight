$Username = "monitoringtech"
$Password = "!Quest4ever"
$FilePath = "/monitoring/secure/"
$ServerName = "ftpamer.quest.com"

$webclient = New-Object System.Net.WebClient


$webclient.Credentials = New-Object System.Net.NetworkCredential($UserName, $Password)
 

$file = $FilePath

$uri = New-Object System.Uri(“https://ftpamer.quest.com/jola.txt”)

$webclient.UploadFile($uri, $FilePath)
