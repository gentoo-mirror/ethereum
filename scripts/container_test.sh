#!/bin/env bash

set -e -u -o pipefail

running_in_docker() {
  awk -F/ '$2 == "docker"' /proc/self/cgroup | read
}

running_in_docker
eselect news read --quiet

EMERGE='emerge --buildpkg --usepkg'
which git 2>/dev/null || {
    USE='-blksha1 -gpg -iconv -nls -pcre -pcre-jit -perl -threads -webdav' $EMERGE dev-vcs/git
}
which equery 2>/dev/null || {
    $EMERGE app-portage/gentoolkit
}

REPO_NAME='ethereum'
emerge --sync $REPO_NAME

atoms() {
    portageq --repo=$REPO_NAME pquery | \
    while read EBUILD ; do
        echo "=${EBUILD}::${REPO_NAME}"
    done
}

atom_use() {
    local ATOM=$1
    equery -qCN uses $ATOM | \
    while read FLAG ; do
        echo -n ${FLAG#-}
    done
}

set -x
atoms | \
while read ATOM ; do
    USE=$( atom_use $ATOM )
    echo "$ATOM $USE" >/etc/portage/package.use/ethereum
    $EMERGE --onlydeps $ATOM
    FEATURES='test' emerge $ATOM
    emerge --unmerge $ATOM
done

