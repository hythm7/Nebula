#!/usr/bin/env bash

PROTO="$(pwd)/proto"

if [ "$#" -lt 3 ]; then 
  echo you need to specify name age source;
  exit 0;
fi

if [ ! -d $PROTO ]; then 
  echo proto dir does not exist!-age;
  exit 1;
fi

NAME="$1"
AGE="$2"
SOURCE="$3"

mkdir -p "$PROTO/$NAME/$NAME-$AGE-x86_64-0-helix"

if [ "$4" == "pre-form" ]; then 

  PREFORM="$PROTO/$NAME/$NAME-$AGE-x86_64-0-helix/pre-form"

  echo '#!/usr/bin/env sh' > $PREFORM

  chmod +x $PREFORM

fi

cat << PROTO > "$PROTO/$NAME/$NAME-$AGE-x86_64-0-helix/proto"
<proto>
  star $NAME-$AGE-x86_64-0-helix
  source $SOURCE

<configure>

  ./configure --prefix=/tools;

<compile>
  make -j [NPROC];

<install>
  make DESTDIR=[XYZ] install;

<desc>
  $NAME.
PROTO


