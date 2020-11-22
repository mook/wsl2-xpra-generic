build:
	docker build --tag ghcr.io/mook/wsl2-xpra-generic .

build-xeyes:
	docker build --file=Dockerfile.xeyes --tag ghcr.io/mook/wsl2-xpra-xeyes .
