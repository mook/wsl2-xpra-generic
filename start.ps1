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
    param ( [string]$Path )
    $Path -replace "\\", "/"
}

function Get-RandomString {
    param ([int]$Length = 32)
    $Range = (48..57) + (97..122)
    -Join ( 1 .. $Length | ForEach { [char]( Get-Random $Range ) } )
}

$ErrorActionPreference = "Stop"
$ScriptPath = Get-UnixPath $PSCommandPath

switch ($Mode) {
    "Start" {
        $ContainerName = Get-RandomString 16
        $Command = "PowerShell.exe", "-NoLogo", "-NonInteractive", `
            "-File", "`"$ScriptPath`"", `
            "-Mode", "SSH", "-DockerImage", "`"$DockerImage`"", `
            "--%"
        xpra `
            --ssh="$($Command -Join " ")" `
            --clipboard-direction=to-server `
            --webcam=no `
            attach "ssh://docker-user@${ContainerName}"
        Assert-ExitStatus
    }
    "SSH" {
        # Skip all the stuff that XPRA is doing to find itself; we have control
        # of the target file system.
        docker run --rm --shm-size ( 256 * 1024 * 1024 ) --interactive $DockerImage
        Assert-ExitStatus
    }
}
