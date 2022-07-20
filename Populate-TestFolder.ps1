$root = $PSScriptRoot
$folds = Get-ChildItem ~ | Where-Object {$_.Name -in "3D Objects","Favorites","Desktop","Documents","Downloads","Music","Pictures","Videos"}

$filesDir = "{0}\{1}" -f $root,"Files"
foreach($fol in $folds) {
    $UserFolder = "{0}\{1}" -f $filesDir,$fol.Name
    New-Item $UserFolder -ItemType Directory
    Write-Output "Test File" | Out-File $UserFolder\1.txt
    Write-Output "Test File" | Out-File $UserFolder\2.txt
}