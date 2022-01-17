setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  TESTDIR=$(mktemp -d -t testsolr-XXXXXXXXXX)
  PROJNAME=testsolr
  ddev delete -Oy ${PROJNAME} || true
  export DDEV_NON_INTERACTIVE=true
  cd "${TESTDIR}" || exit 1
  ddev config --project-name=${PROJNAME} --project-type=drupal9 --docroot=web --create-docroot --mutagen-enabled
  ddev composer create -y -n --no-install drupal/recommended-project
  ddev composer require -n --no-install drush/drush:* drupal/search_api_solr
  ddev composer install -n
  # This restart shouldn't be required, will need to fix in ddev
  mkdir -p web/sites/default/files/sync
  ddev restart
  ddev import-db --src=${DIR}/testdata/db.sql.gz
}

teardown() {
    ddev delete -Oy ${DDEV_SITENAME}
    rm -rf ${TESTDIR}
}

@test "basic installation" {
  pushd ${TESTDIR} >/dev/null
  ddev service get ${DIR}
  ddev restart
  set | grep DDEV
  set -x
  curl -s -L -I http://${DDEV_SITENAME}.${DDEV_TLD}:8983/solr/#/~cores/dev
  set +x
}
