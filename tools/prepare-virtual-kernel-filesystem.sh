#!/usr/bin/env sh

GLX="/home/hythm/glx"

mkdir -pv $GLX/{dev,proc,sys,run}

mknod -m 600 $GLX/dev/console c 5 1
mknod -m 666 $GLX/dev/null c 1 3

mount -v --bind /dev $GLX/dev

mount -vt devpts devpts $GLX/dev/pts -o gid=5,mode=620
mount -vt proc proc $GLX/proc
mount -vt sysfs sysfs $GLX/sys
mount -vt tmpfs tmpfs $GLX/run

if [ -h $GLX/dev/shm ]; then
  mkdir -pv $GLX/$(readlink $GLX/dev/shm)
fi

mount --bind /home/hythm/ /home/hythm/glx/home/hythm
mount --bind /var/nebula/core /home/hythm/glx/var/nebula/core

