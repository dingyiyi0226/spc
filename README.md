# SPC
SPC lets you transfer files and folders to multiple computers easily.

<img src="example.gif" alt="example" width="600"/>

## Features
- Using a short name to identify each remote machine
- Transfer multiple files/folders simutaneously
- Intuitive operations 

## Installation
1. Clone this repo
    ```
    git clone git@github.com:dingyiyi0226/spc.git ~/.spc
    ```

2. Define `SPC_DIR` and initialize spc. For Zsh or other shell user, subsitute `.bash_profile` for the corresponding configuration file.
    ```
    echo 'export SPC_DIR="$HOME/.spc"' >> ~/.bash_profile
    echo 'export PATH="$SPC_DIR/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(spc init)"' >> ~/.bash_profile
    ```

3. Restart the shell
    ```
    exec "$SHELL"
    ```

## How to use
### Set up remote machines
1. Create a remote machine
    ```
    spc create mypc myname@1.1.1.1
    ```

2. Set/Modify the configurations if needed ([the supported configurations](#configurations))
    ```
    spc update mypc -P=8787 uploaddir=/home/me/Desktop
    ```

3. Set the machine as default
    ```
    spc default mypc
    ```

4. You can also get all avalible remote machines and configurations on each machine
    ```
    spc remotes
    spc remote mypc
    ```

### Transmit files/folders to remote machines
After setting the machine `mypc` as default, we can transfer files easliy!

- Transfer to default machine
    ```
    spc file1.txt file2.txt dir1/
    spc download remoteFile1.txt remoteFile2.txt remoteDir1/
    ```

- Transfer to specific machine
    ```
    spc -r mypc file1.txt file2.txt dir1/
    spc download -r mypc remoteFile1.txt remoteFile2.txt remoteDir1/
    ```

## Configurations
For each remote machines, we can store these configurations:

- **address**. Must exists, set automatically when you create the machine. Contains the informations of hostname and ip. (e.g. `myname@100.100.100.100`)
- **uploaddir**. The remote directory that stored uploaded files. The default directory is `~/`.  (Must set as absolute path)
- **downloaddir**. The local directory that stored downloaded files. The default directory is `~/`. (Must set as absolute path)
- **`scp` args**. 

## Commands

spc support these commands:

- [`spc`](#spc-upload) (same as `spc upload`)
- [`spc upload`](#spc-upload)
- [`spc download`](#spc-download)
- [`spc create`](#spc-create)
- [`spc delete`](#spc-delete)
- [`spc update`](#spc-update)
- [`spc remove`](#spc-remove)
- [`spc remote`](#spc-remote)
- [`spc remotes`](#spc-remotes)
- [`spc default`](#spc-default)

### File transmitting commands
#### `spc upload`
Upload file/folders to remote machine

    spc [upload] [-r <remote-name>] [-d <upload-directory>] [-c <config-string>] <file> <file2> <...>

`<upload-directory>` can be a absolute/relative path if the path w/wo a leading `/`

#### `spc download`
Download file/folders from remote machine

    spc download [-r <remote-name>] [-d <download-directory>] [-c <config-string>] <file1> <file2> <...>

`<download-directory>` can be a absolute/relative path if the path w/wo a leading `/`

### Remote setting commands

#### `spc create`
Create a new remote machine

    spc create <remote-name> <address>

#### `spc delete`
Delete a remote machine

    spc delete <remote-name>

#### `spc update`
Update the remote machine configurations

    spc update <remote-name> <config> <config2> <...>

#### `spc remove`
Remove the remote machine configurations

    spc remove <remote-name> <config-key> <config-key2> <...>

#### `spc remote`
Show the remote machine configurations

    spc remote [<remote-name>]

#### `spc remotes`
List all remote machines

    spc remotes [--raw]

#### `spc default`
Set the default remote machine

    spc default <remote-name>

## Credits
SPC is inspired by [pyenv](https://github.com/pyenv/pyenv)

