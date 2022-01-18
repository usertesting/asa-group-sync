# asa-group-sync

A service which gets users in a UNIX group (in this case managed by Okta Advanced Server Access) and adds them to local UNIX groups.
## How does it work

* The install.sh script pulls down the script and installs `asa_group_sync.sh` as a service
* The `asa_group_sync.sh` script adds all users in ${ASA_AUTHORIZED_GROUP} to ${LOCAL_GROUPS}
* The `asa_group_sync.sh` script is run periodically via cron/systemd
