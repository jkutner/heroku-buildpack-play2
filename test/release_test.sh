#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

_createPlayApp() {
  cp -r ${BUILDPACK_HOME}/test-app/* ${BUILD_DIR}
}

testRelease()
{
  _createPlayApp
  
  expected_release_output=`cat <<EOF
---
config_vars:
  PATH: .jdk/bin:/usr/local/bin:/usr/bin:/bin
  JAVA_OPTS: -Xmx384m -Xss512k -XX:+UseCompressedOops
addons:
  heroku-postgresql:dev

default_process_types:
  web: target/universal/stage/bin/starter-project
EOF`

  release

  assertCapturedSuccess
  assertCapturedEquals "${expected_release_output}"
}
