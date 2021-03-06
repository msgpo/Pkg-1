#!/bin/ash

# Pkg can be installed in a chroot or elswhere - experts only
SYSROOT=${SYSROOT:-''}

[ -n "$SYSROOT" ] && \
  [ "${SYSROOT:0:1}" = '/' ] && \
  echo "Error: $SYSROOT: must be absolute path to install Pkg" && exit 1

# get version from current dir
VER=$(while read ver; do [ "${ver:0:6}" = 'APPVER' ] && ver=${ver#*=} && ver=${ver/\"/} && ver=${ver/\"/} && echo $ver && break;done < usr/sbin/pkg)

pkgname=pkg-${VER}-noarch

if [ -z "$SYSROOT" ] ; then
  mkdir -p /tmp/pkg 2>/dev/null
	
  # dont overwrite the existing ~/.pkg/sources[-all] files, if they exist
	
  for existing_file in /root/.pkg/sources /root/.pkg/sources-all /root/.pkg/sources-user
  do
    [ -f "$existing_file" ] && mv "$existing_file" /tmp/pkg/
  done
	
  mv /usr/sbin/pkg /usr/sbin/pkg.previous 2>/dev/null
fi

# copy over our new Pkg files

cp -r etc/ root/ sbin/ usr/ ${SYSROOT}/ && echo -e "Pkg installed OK \n" || echo -e "Pkg was NOT installed! \n"

if [ -z "$SYSROOT" ] ; then
  # list all Pkg files (not including sources files, cos user might want to keep their added repos)
  find etc/ root/ sbin/ usr/ | sed -e 's/^/\//g' > ~/.packages/${pkgname}.files

  # put the files back again
  for existing_file in /tmp/pkg/sources /tmp/pkg/sources-all /tmp/pkg/sources-user
  do
    [ -f $existing_file ] && mv $existing_file /root/.pkg/
  done
fi

# fix version and date in man page
DATE="$(date '+%B %Y')"
sed -e "s/VERSION_PLACEHOLDER/$VER/g" \
  -e "s/DATE_PLACEHOLDER/$DATE/" \
  < usr/share/man/man1/pkg.1 > ${SYSROOT}/usr/share/man/man1/pkg.1

[ -n "${SYSROOT}" ] && exit # silent exit

[ -s ~/.packages/${pkgname}.files ] && echo -e "Package contents listed in ~/.packages/${pkgname}.files \n"

echo -e "Setting up Pkg... \n"

pkg update-sources &>/dev/null

echo
pkg welcome
echo

pkg repo-update && \
{
  sleep 0.1
  echo -e "\nAvailable repos: \n"
  pkg repo-list

  echo
  echo 'For a basic intro, use `pkg welcome`'
  echo 'For more help, use `pkg help`, `pkg help-all` or `pkg usage`'
  echo
}

exit 0
