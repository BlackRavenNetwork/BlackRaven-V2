package=bls-dash
# v20181101 matches src/bls (PublicKey/Signature API). 1.1.0 removed those headers.
$(package)_version=v20181101
$(package)_download_path=https://github.com/dashpay/bls-signatures/archive
$(package)_download_file=$($(package)_version).tar.gz
$(package)_file_name=$(package)-$($(package)_download_file)
$(package)_build_subdir=build
$(package)_sha256_hash=b3ec74a77a7b6795f84b05e051a0824ef8d9e05b04b2993f01040f35689aa87c
$(package)_dependencies=gmp cmake
$(package)_patches=relic-blake2-gcc11.patch

define $(package)_preprocess_cmds
  for i in $($(package)_patches); do patch -p1 < $($(package)_patch_dir)/$$$$i; done && \
  cp $(host_prefix)/include/gmp.h contrib/relic/include/ && \
  sed -i 's|#include "relic_test.h"|/* relic_test.h omitted for release builds */|' src/*.hpp
endef

define $(package)_set_vars
  $(package)_config_opts=-DCMAKE_INSTALL_PREFIX=$($(package)_staging_dir)/$(host_prefix)
  $(package)_config_opts+= -DCMAKE_PREFIX_PATH=$(host_prefix)
  $(package)_config_opts+= -DGMP_INCLUDE_DIR=$(host_prefix)/include -DGMP_LIBRARY=$(host_prefix)/lib/libgmp.a
  $(package)_config_opts+= -DSTLIB=ON -DSHLIB=OFF -DSTBIN=ON
  $(package)_config_opts_linux=-DOPSYS=LINUX -DCMAKE_SYSTEM_NAME=Linux
  $(package)_config_opts_darwin=-DOPSYS=MACOSX -DCMAKE_SYSTEM_NAME=Darwin
  $(package)_config_opts_mingw32=-DOPSYS=WINDOWS -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SHARED_LIBRARY_LINK_C_FLAGS="" -DCMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS=""
  $(package)_config_opts_i686+= -DWSIZE=32
  $(package)_config_opts_x86_64+= -DWSIZE=64
  $(package)_config_opts_arm+= -DWSIZE=32
  $(package)_config_opts_armv7l+= -DWSIZE=32
  $(package)_config_opts_debug=-DDEBUG=ON -DCMAKE_BUILD_TYPE=Debug

  ifneq ($(darwin_native_toolchain),)
    $(package)_config_opts_darwin+= -DCMAKE_AR="$(host_prefix)/native/bin/$($(package)_ar)"
    $(package)_config_opts_darwin+= -DCMAKE_RANLIB="$(host_prefix)/native/bin/$($(package)_ranlib)"
  endif
endef

define $(package)_config_cmds
  export CC="$($(package)_cc)" && \
  export CXX="$($(package)_cxx)" && \
  export CFLAGS="-I$(host_prefix)/include $($(package)_cflags) $($(package)_cppflags)" && \
  export CXXFLAGS="-I$(host_prefix)/include $($(package)_cxxflags) $($(package)_cppflags)" && \
  export CPPFLAGS="-I$(host_prefix)/include $($(package)_cppflags)" && \
  export LDFLAGS="$($(package)_ldflags)" && \
  $(host_prefix)/bin/cmake .. $($(package)_config_opts)
endef

define $(package)_build_cmds
  export CFLAGS="-I$(host_prefix)/include $($(package)_cflags) $($(package)_cppflags)" && \
  export CXXFLAGS="-I$(host_prefix)/include $($(package)_cxxflags) $($(package)_cppflags)" && \
  export CPPFLAGS="-I$(host_prefix)/include $($(package)_cppflags)" && \
  $(MAKE) $($(package)_build_opts) combined_custom
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_staging_dir)/$(host_prefix)/include/bls-dash && \
  mkdir -p $($(package)_staging_dir)/$(host_prefix)/lib && \
  cp -a ../src/*.hpp $($(package)_staging_dir)/$(host_prefix)/include/bls-dash/ && \
  cp -a ../contrib/relic/include/*.h $($(package)_staging_dir)/$(host_prefix)/include/bls-dash/ && \
  cp -a contrib/relic/include/relic_conf.h $($(package)_staging_dir)/$(host_prefix)/include/bls-dash/ && \
  if test -f $($(package)_staging_dir)/$(host_prefix)/include/bls-dash/gmp.h; then \
    sed -i '/__GMP_DECLSPEC_XX std::/d' $($(package)_staging_dir)/$(host_prefix)/include/bls-dash/gmp.h; \
  fi && \
  cp -a libchiabls.a $($(package)_staging_dir)/$(host_prefix)/lib/libbls-dash.a
endef
