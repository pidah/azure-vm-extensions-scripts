defaults() {
    STERLING_JVMS_USER=stradmin
    STERLING_JVMS_CONTROL_SCRIPT=/opt/IBM/bin/servercontrol.sh
}

collect() {
    status=$(su - ${STERLING_JVMS_USER} -c "${STERLING_JVMS_CONTROL_SCRIPT} status all")
    total="$(echo "${status}" | wc -l)"
    running="$(echo "${status}" | grep -c "running")"
    running_fraction="$(echo "$running $total" | awk '{ print $1 / $2 }')"
    report "total" "${total}"
    report "running" "${running}"
    report "running_fraction" "${running_fraction}"

    while read -r agent state; do
        if [[ "$state" == "running" ]]; then
            report "${agent}.up" "1"
        else
            report "${agent}.up" "0"
        fi
    done <<< "${status}"
}


docs() {
    echo "Status of sterling JVMs (running/total)"
    echo "STERLING_JVMS_USER=${STERLING_JVMS_USER}"
    echo "STERLING_JVMS_CONTROL_SCRIPT=${STERLING_JVMS_CONTROL_SCRIPT}"
}