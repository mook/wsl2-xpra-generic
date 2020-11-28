# xpra-generic

This is a base Docker image for running X11-based applications in Docker on
WSL2.

## Building Derivative Images

1. Build an image based upon this one, with the following:
    1. Add `USER docker-user` towards the end (after installing anything else
       needed).
    2. Add `ENTRYPOINT [ "/usr/local/bin/entrypoint.sh", <prog>, <args...> ]`
2. Edit the `start.ps1` script to change the image name.

See [`Dockerfile.xeyes`] for an example.

[`Dockerfile.xeyes`]: ./Dockerfile.xeyes

## Usage

Run `start.ps1` in PowerShell to start a container.  To do one-off runs of
custom images, manually set `-DockerImage`.  For example:

```powershell
.\start.ps1 -DockerImage ghcr.io/mook/wsl2-xpra-xeyes
```

This file can be generate by running the base container with `--start-script`:

```bash
docker run --rm ghcr.io/mook/wsl2-xpra-generic \
    --start-script ghcr.io/mook/wsl2-xpra-xeyes:latest > start.ps1
```
