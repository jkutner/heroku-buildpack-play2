#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testRelease()
{
  mkdir -p ${BUILD_DIR}/target/universal/stage/bin
  touch ${BUILD_DIR}/target/universal/stage/bin/start-project
  chmod +x ${BUILD_DIR}/target/universal/stage/bin/start-project

  expected_release_output=`cat <<EOF
---
config_vars:
  PATH: .jdk/bin:/usr/local/bin:/usr/bin:/bin
  JAVA_OPTS: -Xmx384m -Xss512k -XX:+UseCompressedOops
addons:
  heroku-postgresql:dev

default_process_types:
  web: target/universal/stage/bin/starter-project -Dhttp.port=\$PORT
EOF`

  release

  assertCapturedSuccess
  assertCapturedEquals "${expected_release_output}"
}
