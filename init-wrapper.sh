#!/bin/bash -xv

function run_init_wrapper
{
    unset INIT_WRAPPER
    exec /usr/local/sbin/init "$@"
}


function run_bash
{
    unset INIT_WRAPPER
    exec /bin/bash "$@"
}
# exit-on-finished -U -r "${IPA_SERVER_HOSTNAME}" --setup-dns --no-forwarders --auto-reverse --allow-zone-overlap --no-ntp
[ "${INIT_WRAPPER}" == "1" ] && run_init_wrapper exit-on-finished -U -r "${IPA_SERVER_HOSTNAME}" --setup-dns --no-forwarders --auto-reverse --allow-zone-overlap --no-ntp --verbose
[ "${INIT_WRAPPER}" == "2" ] && run_bash "$@"
unset INIT_WRAPPER

ls -l /usr/sbin/original/init /usr/lib/systemd/systemd
exec /usr/sbin/original/init "$@"
