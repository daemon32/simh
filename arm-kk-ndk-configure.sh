#!/bin/bash
#
# Go to the directory containing the configure script.
#
# Then just run something like:
#
EXAMPLE="~/android-ndk-r9 ./ndk-configure.sh android-9 arch-arm"

if [ -z "${NDK}" ]; then
    echo "Need to specify NDK environment variable when calling."
    echo "  -- e.g. ${EXAMPLE}"
    exit 1
fi

if [ "$#" -lt "2" ]; then
    echo "Usage: ./ndk-configure.sh <platform> <architecture>"
    echo "  -- e.g. ${EXAMPLE}"
    exit 1
else
    PLATFORM=$1
    shift

    ARCHITECTURE=$1
    shift


    COMPILER_VERSION="4.9"

    export NDK_TOOLCHAIN=${NDK}/toolchains/arm-linux-androideabi-${COMPILER_VERSION}/prebuilt/linux-x86_64/bin
    export CROSS_COMPILE=arm-linux-androideabi

    export AR=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ar
    export CC=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-gcc
    export GCC="$CC"
    export CXX=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-g++
    export CXXCPP=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-cpp
    export LD=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ld
    export NM=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-nm
    export OBJDUMP=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-objdump
    export RANLIB=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ranlib
    export STRIP=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-strip

    export SYSROOT=${NDK}/platforms/${PLATFORM}/${ARCHITECTURE}                  # Needed for the Android-specific headers and libs.
    export CXX_SYSROOT=${NDK}/sources/cxx-stl/gnu-libstdc++/${COMPILER_VERSION}  # Needed for the STL headers and libs.
    export CXX_BITS_INCLUDE=${CXX_SYSROOT}/libs/armeabi/include                  # Needed for the <bits/c++config.h> and other headers.
                                                                                 # Certain STL classes, like <unordered_map> won't be 
                                                                                 # usable otherwise.

    export CPPFLAGS="-I${SYSROOT}/usr/include"
    export CFLAGS="--sysroot=${SYSROOT} -mhard-float -D_NDK_MATH_NO_SOFTFP=1 -mfpu=neon -mtune=cortex-a15 -Dfopen64=fopen -Dfseeko64=fseeko -Dftello64=ftello -fPIE -pie -Wl,--no-warn-mismatch -lm_hard"
    export CFLAGS_G="$CFLAGS"
    export CXXFLAGS="--std=c++11 --sysroot=${SYSROOT} -I${CXX_SYSROOT}/include -I${CXX_BITS_INCLUDE}"

    export LIBS="-lc"
    export LDFLAGS="-Wl,-rpath-link=${SYSROOT}/usr/lib -L${SYSROOT}/usr/lib -L${CXX_SYSROOT}/lib"

    export ac_cv_func_malloc_0_nonnull=yes
    export ac_cv_func_realloc_0_nonnull=yes
    
    MACHINE=$( ${CXX} -dumpmachine )

    echo "Machine:           ${MACHINE}"
    echo "Sysroot (Android): ${SYSROOT}"
    echo "Sysroot (cxx):     ${CXX_SYSROOT}"
    echo "Bits include:      ${CXX_BITS_INCLUDE}"

    argString=""
    
    while [ "$1" != "" ]; do
	argString="${argString} $1"
	shift
    done

echo $CC
echo $NDK_TOOLCHAIN
echo $CFLAGS_G
echo $LD
echo $LDFLAGS
    make -j4 # vax780 microvax2 vax
    
#    ./configure --host="${MACHINE}" --target="${MACHINE}" --with-sysroot="${SYSROOT}" $argString

fi
