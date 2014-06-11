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

_primePlayTestCache()
{
  local sbtVersion=${1:-${DEFAULT_SBT_VERSION}}

  # exit code of app compile is cached so it is consistant between runn
  local compileStatusFile=${SBT_TEST_CACHE}/${sbtVersion}/app/compile_status

  if [ ! -f ${compileStatusFile} ]; then
    [ -d ${SBT_TEST_CACHE}/${sbtVersion} ] && rm -r ${SBT_TEST_CACHE}/${sbtVersion}

    ORIGINAL_BUILD_DIR=${BUILD_DIR}
    ORIGINAL_CACHE_DIR=${CACHE_DIR}

    BUILD_DIR=${SBT_TEST_CACHE}/${sbtVersion}/app/build
    CACHE_DIR=${SBT_TEST_CACHE}/${sbtVersion}/app/cache
    mkdir -p ${BUILD_DIR} ${CACHE_DIR}


    cp -r ${BUILDPACK_HOME}/test-app/* ${BUILD_DIR}

    ${BUILDPACK_HOME}/bin/compile ${BUILD_DIR} ${CACHE_DIR} >/dev/null 2>&1
    echo "$?" > ${compileStatusFile}

    BUILD_DIR=${ORIGINAL_BUILD_DIR}
    CACHE_DIR=${ORIGINAL_CACHE_DIR}
  fi

  return $(cat ${compileStatusFile})
}

_primeIvyCache()
{
  local sbtVersion=${1:-${DEFAULT_SBT_VERSION}}

  ivy2_path=.sbt_home/.ivy2
  mkdir -p ${CACHE_DIR}/${ivy2_path}
  _primePlayTestCache ${sbtVersion} && cp -r ${SBT_TEST_CACHE}/${sbtVersion}/app/cache/${ivy2_path}/cache ${CACHE_DIR}/${ivy2_path}
}

_createPlayApp() {
  local sbtVersion=${1:-${DEFAULT_SBT_VERSION}}

  _primeIvyCache ${sbtVersion}
}

testCompile() {
  _createPlayApp

  # create `testfile`s in CACHE_DIR and later assert `compile` copied them to BUILD_DIR
  # mkdir -p ${BUILD_DIR}/.sbt_home
  mkdir -p ${CACHE_DIR}/.sbt_home

  compile

  assertCapturedSuccess

  # setup
  # assertTrue "Activator repo should have been repacked." "[ -d ${BUILD_DIR}/.sbt_home ]"

  # run
  assertCaptured "Activator tasks to run should be output" "Running: activator stage"

  # clean up
  # assertEquals "SBT cache should have been repacked" "" "$(diff -r ${BUILD_DIR}/.sbt_home ${CACHE_DIR}/.sbt_home)"

  # re-deploy
  compile

  assertCapturedSuccess
  assertNotCaptured "Activator should not re-download Scala" "Getting Scala"
  assertNotCaptured "Activator should not re-download any dependencies" "[info] downloading"
  assertNotCaptured "Activator should not resolve any dependencies" "[info] Resolving"
  assertCaptured "Activator tasks to run should still be outputed" "Running: activator stage"
}
