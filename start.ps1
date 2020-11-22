# PowerShell script to launch a XPRA-based container on WSL2

param (
    [ValidateSet("Start", "SSH")]
    [string]$Mode = "start",

    # Edit this to point to your docker image
    [string]$DockerImage = "ghcr.io/mook/wsl2-xpra-generic:latest"
)

function Assert-ExitStatus {
    if (!$?) {
        Exit $LastExitCode
    }
}

function Get-UnixPath {
    param (
        [string]$Path
    )
    $Path -replace "\\", "/"
}

$ErrorActionPreference = "Stop"
$ScriptPath = Get-UnixPath $PSCommandPath

switch ($Mode) {
    "Start" {
        docker create --shm-size ( 256 * 1024 * 1024 ) $DockerImage `
            | Set-Variable -Name ContainerID
        Assert-ExitStatus
        $Env:CONTAINER_ID = $ContainerID

        try {
            docker start $ContainerID
            Assert-ExitStatus
            # The full name is too long, induces issues with the notification
            # icon on Windows ("string too long (83, maximum length 64)")
            $ShortContainerID = $ContainerID.Substring(0, 16)
            xpra_cmd `
                --ssh="powershell.exe -NoLogo -NonInteractive -File ${ScriptPath} -Mode SSH --%" `
                --clipboard-direction=to-server `
                --webcam=no `
                attach "ssh://docker-user@${ShortContainerID}"
            Assert-ExitStatus
        } finally {
            docker rm --force --volumes $ContainerID
            Assert-ExitStatus
        }
    }
    "SSH" {
        # Skip all the stuff that XPRA is doing to find itself; we have control
        # of the target file system.
        docker exec --interactive $Env:CONTAINER_ID /usr/bin/xpra _proxy
        Assert-ExitStatus
    }
}
