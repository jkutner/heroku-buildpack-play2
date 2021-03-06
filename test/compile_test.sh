#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

DEFAULT_SBT_VERSION="0.13.5"
DEFAULT_SBT_JAR="sbt-launch-0.11.3-2.jar"
SBT_TEST_CACHE="/tmp/sbt-test-cache"

afterSetUp() {
  # Remove play-specific build dir in case it's already there
  rm -rf /tmp/play2_buildpack_build_dir
  # Clear clean compiles...most apps don't need to clean by default
  unset ACTIVATOR_CLEAN
}

_createPlayApp() {
  cp -r ${BUILDPACK_HOME}/test-app/* ${BUILD_DIR}
}

testCompile() {
  _createPlayApp

  # create `testfile`s in CACHE_DIR and later assert `compile` copied them to BUILD_DIR
  mkdir -p ${CACHE_DIR}/.sbt_home

  compile

  assertCapturedSuccess
  assertCaptured "Activator tasks to run should be output" "Running: activator stage"
  assertNotCaptured "Activator task failed" "! Failed to build app with activator"

  # re-deploy
  compile

  assertCapturedSuccess
  assertNotCaptured "Activator should not re-download Scala" "Getting Scala"
  assertNotCaptured "Activator should not re-download any dependencies" "[info] downloading"
  assertNotCaptured "Activator should not resolve any dependencies" "[info] Resolving"
  assertCaptured "Activator tasks to run should still be outputed" "Running: activator stage"
  assertNotCaptured "Activator task failed" "! Failed to build app with activator"
}
