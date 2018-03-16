#!/bin/bash
#
# Copyright 2016 leenjewel
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -u

source ./_shared.sh

# Setup architectures, library name and other vars + cleanup from previous runs
# ftp://xmlsoft.org/libxml2/libxml2-2.7.2.tar.gz
TOOLS_ROOT=`pwd`
LIB_NAME="libxml2-2.9.7"
LIB_DEST_DIR=${TOOLS_ROOT}/libs
[ -f ${LIB_NAME}.tar.gz ] || wget ftp://xmlsoft.org/libxml2/${LIB_NAME}.tar.gz
# Unarchive library, then configure and make for specified architectures
configure_make() {
  ARCH=$1; ABI=$2;
  [ -d "${LIB_NAME}" ] && rm -rf "${LIB_NAME}"
  tar xfz "${LIB_NAME}.tar.gz"
  pushd "${LIB_NAME}";

  configure $*
  # fix me
  #cp ${TOOLS_ROOT}/../output/android/openssl-${ABI}/lib/libssl.a ${SYSROOT}/usr/lib
  #cp ${TOOLS_ROOT}/../output/android/openssl-${ABI}/lib/libcrypto.a ${SYSROOT}/usr/lib
  #cp -r ${TOOLS_ROOT}/../output/android/openssl-${ABI}/include/openssl ${SYSROOT}/usr/include
	echo "TOOL : $TOOL"
	echo "ABI: $ABI"
	#export CROSS_COMPILE="${TOOL}"
  mkdir -p ${LIB_DEST_DIR}/${ABI}
  ./configure --enable-static \
	  		  --disable-shared \
			  --without-lzma \
			  --host=aarch64-linux-androideabi
			  #--host=aarch64-linux-android
			  #--host=arm-linux-gnueabi
			  #--host=arm-linux-androideabi
			  #--host=aarch64-linux-gnueabi
  
  #./configure --prefix=${LIB_DEST_DIR}/${ABI} \
              ##--sysroot=${SYSROOT} \
              ##--host=${TOOL} \
              #--enable-static \
              #--disable-shared 
  PATH=$TOOLCHAIN_PATH:$PATH
  #make clean
  make
  #if make -j4
  #then
    #make install

    #OUTPUT_ROOT=${TOOLS_ROOT}/../output/android/curl-${ABI}
    #[ -d ${OUTPUT_ROOT}/include ] || mkdir -p ${OUTPUT_ROOT}/include
    #cp -r ${LIB_DEST_DIR}/${ABI}/include/curl ${OUTPUT_ROOT}/include

    #[ -d ${OUTPUT_ROOT}/lib ] || mkdir -p ${OUTPUT_ROOT}/lib
    #cp ${LIB_DEST_DIR}/${ABI}/lib/libcurl.a ${OUTPUT_ROOT}/lib
  #fi;
  popd;
}

for ((i=0; i < ${#ARCHS[@]}; i++))
do
  if [[ $# -eq 0 ]] || [[ "$1" == "${ARCHS[i]}" ]]; then
    [[ ${ANDROID_API} < 21 ]] && ( echo "${ABIS[i]}" | grep 64 > /dev/null ) && continue;
    configure_make "${ARCHS[i]}" "${ABIS[i]}"
  fi
done
