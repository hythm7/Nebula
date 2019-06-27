#!/usr/bin/env sh

GLX=/home/hythm/galaxy-linux

chroot "$GLX" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(glx) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h

