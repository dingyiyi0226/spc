# SPC
SPC lets you scp to multiple computers easily.

![screenshot](screenshot.png)

## Features
- store multiple ip address by a short name
- set the default address 
- upload/download multiple files/folders simutaneously

## Installation
Clone this repo and create a link of the script to `/usr/local/bin/`
```
    git clone git@github.com:dingyiyi0226/spc.git
    ln spc/spc /usr/local/bin/
```

## How to use
Add a remote machine
```
    spc add mypc myname@1.1.1.1
```
Set/Modify the configurations if needed ( parameters to be passed in `scp` command )
```
    spc modify mypc -P=8787
```
Set the choosen machine as default
```
    spc set mypc
```
Send/Download files easily!
```
    spc file1.txt file2.txt dir1/
    spc dn remoteFile1.txt remoteFile2.txt remoteDir1/
```
You can also list all remote machines
```
    spc remotes
```

## Commands

Command | Args | Summary
------- | ---- | -------
(empty) | [Files]                 | upload files to default remote machine
add     | Machine_name Address    | add the machine to the remote list
dn      | [from Machine_name] Files | download files from default/specific remote machine
help    |                         | display all commands
modify  | Machine_name [Configs]  | modify the remote machine config
remote  | [Machine_name]          | show remote machine config
remotes |                         | show remote machine list
set     | Machine_name            | set the default remote machine
to      | Machine_name Files      | upload files to specific remote machine

