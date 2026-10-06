#!/bin/bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -x

tag=$(repo-src/get-version.sh opus)
git clone --depth 1 https://github.com/xiph/opus -b "$tag"
cd opus

OPUS_CMAKE_ARGS=()
if [[ "$RUNNER_OS" == "Windows" && "$TARGET_ARCH" == "arm64" ]]; then
  # MinGW ARM64 has no runtime CPU detection backend. Opus 1.6.1's CMake
  # configuration still adds NEON sources when only OPUS_MAY_HAVE_NEON is
  # disabled, leaving those sources without their required declarations.
  OPUS_CMAKE_ARGS+=(-DOPUS_DISABLE_INTRINSICS=ON)
fi

# NOTE: without CMAKE_INSTALL_PREFIX on Windows, files are installed
# to c:\Program Files.
cmake . \
  "${OPUS_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DOPUS_BUILD_SHARED_LIBRARY=OFF \
  -DOPUS_BUILD_FRAMEWORK=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DOPUS_BUILD_TESTING=OFF \
  -DBUILD_TESTING=OFF \
  -DOPUS_BUILD_PROGRAMS=OFF

make
$SUDO make install
