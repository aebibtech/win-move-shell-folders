# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

$folds = Get-ChildItem ~ | Where-Object {$_.Name -in "3D Objects","Favorites","Desktop","Documents","Downloads","Music","Pictures","Videos"}
foreach($fol in $folds) {
    Write-Host "User Folder:" $fol.FullName
}


function delete {
    cmd /c rmdir /s /q $args
}

function link {
    cmd /c mklink /j $args
}

function Get-Dest {
    Write-Host
    $Dest = Read-Host -Prompt "User Folder Destination" 
    Write-Host
    return $Dest
}

function Move-Folders {
    $dest = $args[0]

    if( !$dest ) {
        Write-Host -ForegroundColor Yellow "No Path Supplied."
        exit
    }

    $msg = "User Folders will be linked/moved to: {0}\" -f $dest
    Write-Host -ForegroundColor Yellow $msg

    cmd /c taskkill /f /im explorer.exe

    $folders = Get-ChildItem ~ | Where-Object {$_.Name -in "3D Objects","Favorites","Desktop","Documents","Downloads","Music","Pictures","Videos"}
    
    foreach ($fol in $folders) {
        $UserFolderPath = $fol.FullName
        
        Write-Host
        Write-Host "Source Folder:" $UserFolderPath
        $UserFolderDestination = "{0}\{1}" -f $dest,$fol.Name
        Write-Host "Destination Folder:" $UserFolderDestination
        Write-Host

        if(Get-ChildItem $UserFolderPath) {
            Write-Host "This folder has the following files"
            Get-ChildItem $UserFolderPath
            
            # User Folder has files and Destination exists,
            # move the files there, delete the user folder, and create a junction.
            if ( Test-Path -Path $UserFolderDestination ) {
                $msg = "Destination {0} exists." -f $UserFolderDestination
                Write-Host $msg

                Get-ChildItem $UserFolderPath | Move-Item -Destination $UserFolderDestination -Force

                delete $UserFolderPath
                link $UserFolderPath $UserFolderDestination
            }

            # User Folder has files and destination does not exist.
            # Create the destination folder, move the files there,
            # delete the user folder, and create a junction.
            if ( !(Test-Path -Path $UserFolderDestination) ) {
                $msg = "Destination {0} does not exist yet. Creating the folder." -f $UserFolderDestination
                Write-Host $msg
                New-Item -ItemType Directory -Path $UserFolderDestination -Force
                Get-ChildItem $UserFolderPath | Move-Item -Destination $UserFolderDestination -Force

                delete $UserFolderPath
                link $UserFolderPath $UserFolderDestination
            }
        } else {

            # User Folder has no files in C:\Users\<user> and Destination exists.
            # Delete the user folder and create a junction.
            if ( Test-Path -Path $UserFolderDestination ) {
                $msg = "Destination {0} exists." -f $UserFolderDestination
                Write-Host $msg

                delete $UserFolderPath
                link $UserFolderPath $UserFolderDestination
            }

            # User Folder has no files and Destination does not exist.
            # create the destination folder, delete the user folder, 
            # and create a junction.
            if ( !(Test-Path -Path $UserFolderDestination) ) {
                $msg = "Destination {0} does not exist yet. Creating the folder." -f $UserFolderDestination
                Write-Host $msg
                New-Item -ItemType Directory -Path $UserFolderDestination -Force

                delete $UserFolderPath
                link $UserFolderPath $UserFolderDestination
            }
        }

        # Start-Sleep -Milliseconds 1500
    }

    # Restore Music, Pictures, Videos junctions in My Documents
    if ( Test-Path $dest\Documents ) {
        $docs = "${dest}\Documents"
        cmd /c mklink /j "${docs}\My Music" "${dest}\Music"
        cmd /c attrib +h "${docs}\My Music" /L
        
        cmd /c mklink /j "${docs}\My Pictures" "${dest}\Pictures"
        cmd /c attrib +h "${docs}\My Pictures" /L
       
        cmd /c mklink /j "${docs}\My Videos" "${dest}\Videos"
        cmd /c attrib +h "${docs}\My Videos" /L
    }

    Start-Process explorer.exe
}

$dest = $args[0]

while ( !$dest ) {
    $dest = Get-Dest
}

if( $dest.EndsWith("\") ) {
    $dest = $dest.TrimEnd("\")
}

Move-Folders $dest

if( !$args[0] ) { cmd /c pause }