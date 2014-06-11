#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

DEFAULT_SBT_VERSION="0.13.5"
DEFAULT_SBT_JAR="sbt-launch-0.11.3-2.jar"
SBT_TEST_CACHE="/tmp/sbt-test-cache"

beforeSetUp() {
  mkdir -p build cache
  cp -r ${BUILDPACK_HOME}/test-app/* build
}

afterSetUp() {
  # Remove play-specific build dir in case it's already there
  rm -rf /tmp/play_buildpack_build_dir
  # Clear clean compiles...most apps don't need to clean by default
  unset ACTIVATOR_CLEAN
}

compilePlay() {
  compile `pwd`/build cache 2>&1
}

testCompile() {

  # create `testfile`s in CACHE_DIR and later assert `compile` copied them to BUILD_DIR
  mkdir -p build/.sbt_home
  mkdir -p cache/.sbt_home

  compilePlay

  assertCapturedSuccess

  # setup
  assertTrue "Activator repo should have been repacked." "[ -d build/.sbt_home ]"

  # run
  assertCaptured "Activator tasks to run should be output" "Running: activator stage"

  # clean up
  assertEquals "SBT cache should have been repacked" "" "$(diff -r build/.sbt_home cache/.sbt_home)"

  # re-deploy
  compilePlay

  assertCapturedSuccess
  assertNotCaptured "Activator should not re-download Scala" "Getting Scala"
  assertNotCaptured "Activator should not re-download any dependencies" "[info] downloading"
  assertNotCaptured "Activator should not resolve any dependencies" "[info] Resolving"
  assertCaptured "Activator tasks to run should still be outputed" "Running: activator stage"
}
