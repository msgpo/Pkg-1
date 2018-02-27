#!/bin/sh

# the build profile

##########
# shared #
##########

# compiler flags
case $(uname -m) in
	i?86)
		LIBDIR_SUFFIX=""
		CFLAGS1="-march=i486 -mtune=i686"
		PKG_ARCH="i486"
		;;
	x86_64)
		LIBDIR_SUFFIX="64"
		CFLAGS1="-march=x86_64 -mtune=generic"
		PKG_ARCH="x86_64"
		;;
esac

export CFLAGS="$CFLAGS1 -Os -fomit-frame-pointer -pipe"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-L/lib,-L/usr/lib,-L/usr/X11R7/lib"
export PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/X11R7/lib/pkgconfig"

# the number of threads
BUILD_THREADS="$(cat /proc/cpuinfo | grep processor | wc -l)"

# the base install prefix for packages
BASE_INSTALL_PREFIX="/usr"

# the package target
BUILD_TARGET="$PKG_ARCH-puppy-linux-gnu"

# the base flags for ./configure or ./autogen.sh
BASE_CONFIGURE_ARGS="--build=$BUILD_TARGET \
                     --libexecdir=$BASE_INSTALL_PREFIX/lib$LIBDIR_SUFFIX/$PKG_NAME \
                     --sysconfdir=/etc --localstatedir=/var \
                     --mandir=$BASE_INSTALL_PREFIX/share/man \
                     --prefix=$BASE_INSTALL_PREFIX --disable-static --enable-shared \
                     --disable-debug --without-pic"

#########
# fonts #
#########

# the default location for TrueType fonts
TTF_FONTS_DIR="/usr/share/fonts/default/TTF"