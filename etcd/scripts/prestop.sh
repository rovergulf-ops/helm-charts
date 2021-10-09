EPS=""
for i in $(seq 0 $((${INITIAL_CLUSTER_SIZE} - 1))); do
    EPS="${EPS}${EPS:+,}${PEER_PROTOCOL}://${SET_NAME}-${i}.${SET_NAME}:2379"
done
HOSTNAME=$(hostname)
member_hash() {
    etcdctl $AUTH_OPTIONS member list | grep ${PEER_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2380 | cut -d ',' -f1
}
SET_ID=${HOSTNAME##*[^0-9]}
if [ "${SET_ID}" -ge ${INITIAL_CLUSTER_SIZE} ]; then
    echo "Removing ${HOSTNAME} from etcd cluster"
    ETCDCTL_ENDPOINT=${EPS} etcdctl $AUTH_OPTIONS member remove $(member_hash)
    if [ $? -eq 0 ]; then
        # Remove everything otherwise the cluster will no longer scale-up
        rm -rf /var/run/etcd/*
    fi
fi