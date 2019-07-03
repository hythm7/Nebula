#!/usr/bin/env sh

GLX=/home/hythm/glx

chroot "$GLX" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(glx) \u:\w\$ ' \
    PATH=/root/bin:/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h

