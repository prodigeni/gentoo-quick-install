#!/bin/bash

source ./config.rc

mirrorselect='/usr/sbin/mirrorselect'

if [ -z "$GENTOO_MIRRORS" ] ; then
    GENTOO_MIRRORS=$( $mirrorselect -s5 -F -o )
    eval $GENTOO_MIRRORS
fi


for mirror in $GENTOO_MIRRORS ; do
    echo "* Mirror: $mirror"
    curl $mirror/releases/$CPU_TYPE/current-iso/ > mirror.listing
    exit_code=$?
    echo "* Result: $exit_code"
    if [ $exit_code -eq 0 ] ; then
        install_file=$( awk '/install.*iso$/{print $9}' mirror.listing )
        stage3_file=$( awk "/stage3-$CPU_ARCH.*bz2\$/{print \$9}" mirror.listing )
        break
    fi
done

echo "
Mirror: $mirror
Install file: $install_file
Stage3 file: $stage3_file
"

