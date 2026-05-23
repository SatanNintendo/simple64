#!/usr/bin/env bash

set -e
set -o pipefail

RELEASE_TYPE="Release"

UNAME=$(uname -s)
PLATFORM=$(uname -m)
if [[ ${UNAME} == *"MINGW64"* ]]; then
  suffix=".dll"
else
  suffix=".so"
fi

install_dir=${PWD}/simple64
mkdir -p "${install_dir}"
base_dir=${PWD}

mkdir -p "${base_dir}/mupen64plus-core/build"
cd "${base_dir}/mupen64plus-core/build"
cmake -G Ninja -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" ..
cmake --build .
cp ./*mupen64plus"${suffix}" "${install_dir}"
cp "${base_dir}/mupen64plus-core/data/mupen64plus.ini" "${install_dir}"
cp "${base_dir}/mupen64plus-core/data/pif"* "${install_dir}"

mkdir -p "${base_dir}/simple64-input-raphnetraw/build"
cd "${base_dir}/simple64-input-raphnetraw/build"
cmake -G Ninja -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" ..
cmake --build .
cp simple64-input-raphnetraw.* "${install_dir}"

mkdir -p "${base_dir}/simple64-input-qt/build"
cd "${base_dir}/simple64-input-qt/build"
cmake -G Ninja -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" ..
cmake --build .
cp simple64-input-qt.* "${install_dir}"

mkdir -p "${base_dir}/simple64-audio-sdl2/build"
cd "${base_dir}/simple64-audio-sdl2/build"
cmake -G Ninja -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" ..
cmake --build .
cp simple64-audio-sdl2.* "${install_dir}"

cd "${base_dir}"
GUI_VERSION_FILE=${base_dir}/simple64-gui/version.h
rev=\"$(git rev-parse HEAD)\"
if [[ -f ${GUI_VERSION_FILE} ]]; then
  lastrev=$(head -n 1 "${GUI_VERSION_FILE}" | cut -d " " -f 3)
else
  lastrev=""
fi

echo current revision "${rev}"
echo last build revision "${lastrev}"

if [[ "${lastrev}" != "${rev}" ]]; then
  echo "#define GUI_VERSION ${rev}" >"${GUI_VERSION_FILE}"
fi

mkdir -p "${base_dir}/simple64-gui/build"
cd "${base_dir}/simple64-gui/build"
cmake -G Ninja -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" ..
cmake --build .
if [[ ${UNAME} == *"MINGW64"* ]]; then
  cp "${base_dir}/simple64-gui/build/simple64-gui.exe" "${install_dir}"
else
  cp "${base_dir}/simple64-gui/build/simple64-gui" "${install_dir}"
fi

mkdir -p "${base_dir}/parallel-rsp/build"
cd "${base_dir}/parallel-rsp/build"
cmake -G Ninja -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" ..
cmake --build .
cp simple64-rsp-parallel.* "${install_dir}"

mkdir -p "${base_dir}/parallel-rdp-standalone/build"
cd "${base_dir}/parallel-rdp-standalone/build"
cmake -G Ninja -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" ..
cmake --build .
cp simple64-video-parallel.* "${install_dir}"

if [[ ! -f "${base_dir}/cheats.json" ]]; then
  cd "${base_dir}"
  curl -sSL -o cheats.json https://raw.githubusercontent.com/simple64/cheat-parser/main/cheats.json || echo "Warning: could not download cheats.json, skipping"
fi

if [[ -f "${base_dir}/cheats.json" ]]; then
  cp "${base_dir}/cheats.json" "${install_dir}"
fi

if [[ ${UNAME} == *"MINGW64"* ]]; then
  cd "${install_dir}"
  WINDEPLOYQT=$(find /d /c /mingw64 -name "windeployqt-qt6.exe" 2>/dev/null | head -1)
  if [[ -z "${WINDEPLOYQT}" ]]; then
    WINDEPLOYQT=$(find /d /c /mingw64 -name "windeployqt6.exe" 2>/dev/null | head -1)
  fi
  echo "Found windeployqt at: ${WINDEPLOYQT}"
  "${WINDEPLOYQT}" --no-translations simple64-gui.exe
  my_os=win64

  # shellcheck disable=SC2154
  cp -v "${MSYSTEM_PREFIX}/bin/libgcc_s_seh-1.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libwinpthread-1.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libstdc++-6.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libdouble-conversion.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/zlib1.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}"/bin/libicuin*.dll "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}"/bin/libicuuc*.dll "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}"/bin/libicudt*.dll "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libbrotlidec.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libbrotlicommon.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libpcre2-16-0.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libpcre2-8-0.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libharfbuzz-0.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libb2-1.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libmd4c.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libpng16-16.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libfreetype-6.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libglib-2.0-0.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/SDL2.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/SDL2_net.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libbz2-1.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libgraphite2.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libintl-8.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libiconv-2.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libzstd.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libhidapi-0.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libcrypto-3-x64.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/libssl-3-x64.dll" "${install_dir}"
  cp -v "${MSYSTEM_PREFIX}/bin/7z.exe" "${install_dir}"
else
  if [[ "${PLATFORM}" == "aarch64" ]]; then
    my_os=linux_aarch64
  else
    my_os=linux_x86_64
  fi
fi

if [[ "$1" == "zip" ]]; then
  cd "${base_dir}"
  rm -f "${base_dir}/"*.zip
  HASH=$(git rev-parse --short HEAD)
  zip --symlinks -r "simple64-${my_os}-${HASH}.zip" simple64
fi
