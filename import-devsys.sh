#!/data/data/com.termux/files/usr/bin/bash

archivelocation=$1
if [ "$archivelocation" == "" ]; then
        echo "No archive specfied"; exit 1;;
fi

folder=devsys-fs
if [ -d "$folder" ]; then
        echo "Already imported"; exit 1;;
fi

tarball="devsys-rootfs.tar.xz"

echo "Downloading Rootfs, this may take a while."
arch=$(dpkg --print-architecture)
#case `dpkg --print-architecture` in
#arm)
#        archurl="armhf" ;;
#amd64)
#        archurl="amd64" ;;
#x86_64)
#        archurl="amd64" ;;
#*)
#        echo "Unknown architecture"; exit 1 ;;
#esac
if [ "$arch" == 'aarch64' ];
then
        wget --tries=20 ${archivelocation} -O ${tarball}
        cur=`pwd`
        mkdir -p "$folder"
        cd "$folder"
        echo "Decompressing Rootfs, please be patient."
        proot --link2symlink tar -xJf ${cur}/${tarball} --exclude='dev'||:
        cd "$cur"
fi

echo "Setting up name server"
echo "127.0.0.1 localhost" > etc/hosts
echo "nameserver 8.8.8.8" > etc/resolv.conf
echo "nameserver 8.8.4.4" >> etc/resolv.conf

mkdir -p devsys-binds
bin=start-devsys.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A fedora-binds)" ]; then
    for f in fedora-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b devsys-fs/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to /
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball
echo "You can now launch devsys with the ./${bin} script next time"
bash $bin
