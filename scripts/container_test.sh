#!/bin/env bash

set -e -u -o pipefail

REPO_NAME='ethereum'
REPO_BRANCH='dev'

running_in_docker() {
  awk -F/ '$2 == "docker"' /proc/self/cgroup | read
}

running_in_docker
eselect news read --quiet

EMERGE='emerge --buildpkg --usepkg --binpkg-respect-use=y'
which git 2>/dev/null || {
    USE='-blksha1 -gpg -iconv -nls -pcre -pcre-jit -perl -threads -webdav' $EMERGE dev-vcs/git
}
emerge --sync $REPO_NAME
which equery 2>/dev/null || {
    $EMERGE app-portage/gentoolkit
}
test "$REPO_BRANCH" = 'master' || {
    EROOT=$( portageq envvar EROOT )
    REPO_PATH=$( portageq get_repo_path "$EROOT" ethereum )
    REPOS_DIR=$( dirname "$REPO_PATH" )
    REPO_URI=$( portageq repos_config "$EROOT" | sed -r -e "/\[${REPO_NAME}]/,/^$/"'!d' -e '/^sync-uri *=/!d' -e 's/.*= *//' )
    (
        cd "$REPOS_DIR"
        rm -rf "$REPO_NAME"
        git clone --branch "$REPO_BRANCH" "$REPO_URI" "$REPO_NAME"
    )
    emerge --sync $REPO_NAME
}

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
    emerge --depclean
done

