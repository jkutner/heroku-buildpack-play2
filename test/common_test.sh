#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/common

testCountFiles() {
   mkdir -p ${BUILD_DIR}/two/three

   touch ${BUILD_DIR}/1.a
   touch ${BUILD_DIR}/1.x
   touch ${BUILD_DIR}/two/2.a
   touch ${BUILD_DIR}/two/2.ax
   touch ${BUILD_DIR}/two/three/3.a
   touch ${BUILD_DIR}/two/three/3.xa

   capture count_files ${BUILD_DIR} '*.a'
   assertCapturedSuccess
   assertCapturedEquals "3"
}

testCountFiles_BadDir() {
   mkdir -p ${BUILD_DIR}/something

   capture count_files ${BUILD_DIR}/something_else '*.a'
   assertCapturedSuccess
   assertCapturedEquals "0"
}

testDetectPlayLang_BadDir() {
  capture detect_play_lang non_existant_dir
  assertCapturedSuccess
  assertCapturedEquals ""
}
