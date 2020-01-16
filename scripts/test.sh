#!/usr/bin/env bash
#
# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# Build everything in a clean Gentoo environment
#
# Rafael Lorandi <coolparadox@gmail.com>
#

set -e -u -o pipefail
set -x

WHEREAMI=$( dirname "$0" )
cd $WHEREAMI

HOST_EROOT=$( portageq envvar EROOT )
HOST_PORTAGE_DIR=$( portageq get_repo_path "$HOST_EROOT" gentoo )
HOST_DISTDIR=$( portageq distdir )
CACHE_PKGDIR=/var/cache/gentoo-ethereum-test/binpkgs

docker build --tag gentoo-ethereum-test .
docker run --rm \
    --mount="type=bind,source=${HOST_PORTAGE_DIR},destination=/var/db/repos/gentoo" \
    --mount="type=bind,source=${HOST_DISTDIR},destination=/var/cache/distfiles" \
    --mount="type=bind,source=${CACHE_PKGDIR},destination=/var/cache/binpkgs" \
    gentoo-ethereum-test \
    /bin/bash -l /root/container_test.sh ${1:-.}

