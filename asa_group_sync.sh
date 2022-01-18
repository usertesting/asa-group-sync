#!/bin/bash -ex

# Ensure non-zero exit codes aren't swallowed by sed pipes
set -o pipefail

ASA_AUTHORIZED_GROUP=${ASA_AUTHORIZED_GROUP:-}
LOCAL_GROUPS=${LOCAL_GROUPS:-}

function get_authorized_users() {
  getent group ${ASA_AUTHORIZED_GROUP} \
  | cut -d : -f4- \
  | sed "s/,/ /g"
}

function update_local_user() {
  set +e
  # append to the local group, don't make any other changes
  usermod -a -G ${LOCAL_GROUPS} ${1}
  set -e
}

function sync_accounts() {
  if [ -z "${ASA_AUTHORIZED_GROUP}" ]; then
    echo "Must specify valid UNIX group for ASA_AUTHORIZED_GROUP" 1>&2
    exit 1
  fi

  authorized_users=$(get_authorized_users)

  for user in ${authorized_users}; do
    update_local_user ${user}
  done
}

sync_accounts
