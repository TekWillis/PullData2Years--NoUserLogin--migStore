
   
# CREATES temp directory
mkdir C:\temp

# REMOVES possible old log files if for some reason the script needs to be ran again. 
Remove-Item C:\temp\migLog.txt
Remove-Item C:\temp\DirLog.txt

# CREATES log file's for entries. 
New-Item C:\temp\migLog.txt
New-Item C:\temp\DirLog.txt
# CREATES empty directories to store data local
# using alias 'md' instead of mkdir
md C:\Users\mig
md C:\Users\mig\Desktop
md C:\Users\mig\Documents
md C:\Users\mig\Photos
md C:\Users\mig\Favorites
md C:\Users\mig\Downloads # this one will likely not be used.  

$comp = Read-host "What is the computers hostname " 
$user = Read-host "What is the user name "
$Curr_date = Get-Date
$Max_days = "-730"

#################
#   Variables   #
#################

# Remote Desktop
$Rdesk = "\\$comp\C$\Users\$user\Desktop\"
# Local Desktop # this has been modified since its original version
$Ldesk = "C:\Users\$user\mig\Desktop\"

#############
############# "Local xxx" has been modifed to a diretory at C:\Users\mig
#############  
# Remote Documents
$Rdocs = "\\$comp\C$\Users\$user\Documents\"
# Local Documents
$Ldocs = "C:\Users\$user\mig\Documents\"

# Remote Pictures
$Rpics = "\\$comp\C$\Users\$user\Pictures\"
# Local Pictures
$Lpics = "C:\Users\$user\mig\Pictures\"


# COPIES Drives.bat file to public desktop
Copy-Item '\\bsdit001\C$\Drives.bat' C:\Users\$user\Desktop 

# COPIES Desktop excluding anything greater than 2 years old as set by the $Max_days variable of -730 days
foreach ($file in (Get-Childitem $Rdesk)){
     if($file.LastWriteTime -gt ($Curr_date).adddays($Max_days))
     {
     Copy-Item -Path $file.fullname -Exclude *.pst -Recurse -Destination $Ldesk -Verbose
}    ELSE
    {"Not copying $file" >> c:\temp\migLog.txt
    }
    }

# COPIES Documents excluding anything greater than 2 years old as set by the $Max_days variable of -730 days
foreach ($file in (Get-Childitem $Rdocs)){
     if($file.LastWriteTime -gt ($Curr_date).adddays($Max_days))
     {
     Copy-Item -Path $file.fullname -Recurse -Exclude *.pst -Destination $Ldocs -Verbose
}    ELSE
    {"Not copying $file" >> c:\temp\migLog.txt
    }
    }


# Copies Pictures excluding anything greater than 2 years as set by the $Max_days variable of -730 days
foreach ($file in (Get-Childitem $Rpics)){
     if($file.LastWriteTime -gt ($Curr_date).adddays($Max_days))
     {
     Copy-Item -Path $file.fullname -Recurse -Destination $Lpics -Verbose
}    ELSE
    {"Not copying $file" >> c:\temp\migLog.txt
    }
    }

#############
#   AS400   #
#############
# COPIES AS400 keymap text file // C:\Users\$user\AppData\Roaming\IBM\Client Access\Emulator\private\AS400.KMP
Copy-Item '\\bsdit001\C$\AS400.KMP' "C:\Users\$user\AppData\Roaming\IBM\Client Access\Emulator\private\"


#################
#   FAVORITES   #
#################
# COPIES IE Favorites
copy-item "\\$comp\C$\Users\$user\Favorites\" -Recurse C:\Users\$user\Favorites -Verbose
# COPIES Google Bookmarks
Copy-item "\\$comp\C$\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Bookmarks*" "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default" -Verbose


#!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!   LOGGING   !!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!#
# WRITES old pc name to top of migLog.txt
Write-Output "Old computer name: $comp" >> C:\temp\migLog.txt

# SEARCHES FOR .PST Recusevly through the entire user profile
Get-ChildItem "\\$comp\C$\Users\$user\" -Filter *pst -Recurse >> C:\temp\migLog.txt


# WRITES old pc name to top of DirLog.txt
Write-Output "Old computer name: $comp" >> C:\temp\DirLog.txt
# WRITES Directory output of users folders & docs to C:\temp\DirLog.txt
Get-ChildItem -Path \\$comp\C$\Users\$user -Recurse >> C:\temp\DirLog.txt

# TEST Path for AS400 key map. 
$AS400 = "C:\Users\$user\AppData\Roaming\IBM\Client Access\Emulator\private\AS400.KMP" 
$fileExist = Test-Path $AS400
if ($fileExist -eq $True){
Write-Output "AS400 Keys Mapped successfulluy" >> C:\temp\migLog.txt
Else {
Write-Output " <<< AS400 KEYS NOT MAPPED >>>" >> C:\temp\migLog.txt}
}

