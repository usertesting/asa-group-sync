#!/bin/bash -ex

INSTALL_PREFIX=${INSTALL_PREFIX:-/usr/local}
PATH=${INSTALL_PREFIX}/bin:${PATH}

REPO=${REPO:-usertesting/asa-group-sync}
BRANCH=${BRANCH:-main}

SCHEDULER=${SCHEDULER:-systemd}
ASA_AUTHORIZED_GROUP=${ASA_AUTHORIZED_GROUP:-}
LOCAL_GROUPS=${LOCAL_GROUPS:-}

export INSTALL_PREFIX PATH REPO BRANCH SCHEDULER ASA_AUTHORIZED_GROUP \
       LOCAL_GROUPS

function fetch() {
  curl -sL https://raw.github.com/${REPO}/${BRANCH}/${1}
}

mkdir -p ${INSTALL_PREFIX}/bin
fetch asa_group_sync.sh > ${INSTALL_PREFIX}/bin/asa_group_sync
chmod +x ${INSTALL_PREFIX}/bin/asa_group_sync


case $SCHEDULER in
cron)
  fetch asa_group_sync.cron |
    sed "s|@@ASA_AUTHORIZED_GROUP@@|${ASA_AUTHORIZED_GROUP}|g" |
    sed "s|@@LOCAL_GROUPS@@|${LOCAL_GROUPS}|g" |
    sed "s|@@INSTALL_PREFIX@@|${INSTALL_PREFIX}|g" |
    sed "s|@@PATH@@|${PATH}|g" > /etc/cron.d/asa_group_sync
  chmod 0644 /etc/cron.d/asa_group_sync
  ;;
systemd)
  fetch asa_group_sync.service |
    sed "s|@@ASA_AUTHORIZED_GROUP@@|${ASA_AUTHORIZED_GROUP}|g" |
    sed "s|@@LOCAL_GROUPS@@|${LOCAL_GROUPS}|g" |
    sed "s|@@INSTALL_PREFIX@@|${INSTALL_PREFIX}|g" |
    sed "s|@@PATH@@|${PATH}|g" > /etc/systemd/system/asa_group_sync.service
  fetch asa_group_sync.timer > /etc/systemd/system/asa_group_sync.timer
  chmod 0644 /etc/systemd/system/asa_group_sync.{service,timer}
  systemctl daemon-reload
  systemctl enable asa_group_sync.timer
  systemctl start asa_group_sync.timer
  ;;
*)
  echo "Unknown scheduler: ${SCHEDULER}" >&1
  exit 1
  ;;
esac

${INSTALL_PREFIX}/bin/asa_group_sync
