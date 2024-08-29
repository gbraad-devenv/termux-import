Import script for Termux 
========================

### Usage
```
$ pkg install proot wget
$ wget https://raw.githubusercontent.com/gbraad-devenv/termux-import/main/import-devsys.sh -O import-devsys.sh
$ chmod +x ./import-devsys.sh
$ ./import-devsys.sh https://github.com/gbraad-devenv/fedora/releases/download/38/devsys-fedora-rootfs-arm64.tar.xz
$ ./start-devsys.sh
```
