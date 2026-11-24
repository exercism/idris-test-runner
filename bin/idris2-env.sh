# Sets the paths that pack would pass to idris2, so that bin/run.sh can call
# idris2 directly without starting pack on every run. Pack names its install
# folders after commit hashes, which change whenever the pack image is bumped,
# so these globs find the folders instead of naming them.

pack_install_dir=$(dirname "${PACK_STATE_DIR}"/install/*/idris2)
idris2_prefix=$(echo "${pack_install_dir}"/idris2/idris2-*)

export PATH="${pack_install_dir}/idris2/bin:${PATH}"
export IDRIS2_LIBS="${idris2_prefix}/lib"
export IDRIS2_DATA="${idris2_prefix}/support"
export IDRIS2_PACKAGE_PATH="${idris2_prefix}$(printf ':%s' "${pack_install_dir}"/*/*/idris2-*)"
