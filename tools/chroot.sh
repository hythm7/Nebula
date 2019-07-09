#!/usr/bin/env sh

GLX=/home/hythm/glx

chroot "$GLX" /usr/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(glx) \u:\w\$ ' \
    PATH=/root/bin:/bin:/usr/bin:/sbin:/usr/sbin \
    /tools/bin/bash --login

