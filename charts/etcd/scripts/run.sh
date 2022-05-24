HOSTNAME=$(hostname)
# store member id into PVC for later member replacement
collect_member() {
    while ! etcdctl $AUTH_OPTIONS member list > /dev/null 2>&1; do sleep 1; done
    etcdctl $AUTH_OPTIONS member list | grep ${PEER_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2380 | cut -d ',' -f1 > /var/run/etcd/member_id
    exit 0
}
eps() {
    EPS=""
    for i in $(seq 0 $((${INITIAL_CLUSTER_SIZE} - 1))); do
        EPS="${EPS}${EPS:+,}${PEER_PROTOCOL}://${SET_NAME}-${i}.${SET_NAME}:2379"
    done
    echo ${EPS}
}
member_hash() {
    etcdctl $AUTH_OPTIONS member list | grep ${PEER_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2380 | cut -d ',' -f1
}
# we should wait for other pods to be up before trying to join
# otherwise we got "no such host" errors when trying to resolve other members
for i in $(seq 0 $((${INITIAL_CLUSTER_SIZE} - 1))); do
    while true; do
        echo "Waiting for ${SET_NAME}-${i}.${SET_NAME} to come up"
        ping -W 5 -c 1 ${SET_NAME}-${i}.${SET_NAME} > /dev/null && break
        sleep 1s
    done
done

# re-joining after failure?
if [ -e /var/run/etcd/default.etcd && -e /var/run/etcd/member_id ]; then
    echo "Re-joining etcd member"
    member_id=$(cat /var/run/etcd/member_id)
    # re-join member
    ETCDCTL_ENDPOINT=$(eps) etcdctl $AUTH_OPTIONS member update ${member_id} ${PEER_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2380 | true
    exec etcd --name ${HOSTNAME} \
        --listen-peer-urls ${PEER_PROTOCOL}://0.0.0.0:2380 \
        --listen-client-urls ${CLIENT_PROTOCOL}://0.0.0.0:2379\
        --advertise-client-urls ${CLIENT_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2379 \

fi
# etcd-SET_ID
SET_ID=${HOSTNAME##*[^0-9]}
# adding a new member to existing cluster (assuming all initial pods are available)
if [ "${SET_ID}" -ge ${INITIAL_CLUSTER_SIZE} ]; then
    export ETCDCTL_ENDPOINT=$(eps)
    # member already added?
    MEMBER_HASH=$(member_hash)
    if [ -n "${MEMBER_HASH}" ]; then
        # the member hash exists but for some reason etcd failed
        # as the datadir has not be created, we can remove the member
        # and retrieve new hash
        etcdctl $AUTH_OPTIONS member remove ${MEMBER_HASH}
    fi
    echo "Adding new member"
    etcdctl $AUTH_OPTIONS member add ${HOSTNAME} ${PEER_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2380 | grep "^ETCD_" > /var/run/etcd/new_member_envs
    if [ $? -ne 0 ]; then
        echo "Exiting"
        rm -f /var/run/etcd/new_member_envs
        exit 1
    fi
    cat /var/run/etcd/new_member_envs
    source /var/run/etcd/new_member_envs
    collect_member &
    exec etcd --name ${HOSTNAME} \
        --listen-peer-urls ${PEER_PROTOCOL}://0.0.0.0:2380 \
        --listen-client-urls ${CLIENT_PROTOCOL}://0.0.0.0:2379 \
        --advertise-client-urls ${CLIENT_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2379 \\
        --initial-advertise-peer-urls ${PEER_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2380 \
        --initial-cluster ${ETCD_INITIAL_CLUSTER} \
        --initial-cluster-state ${ETCD_INITIAL_CLUSTER_STATE}
fi
PEERS=""
for i in $(seq 0 $((${INITIAL_CLUSTER_SIZE} - 1))); do
    PEERS="${PEERS}${PEERS:+,}${SET_NAME}-${i}=${PEER_PROTOCOL}://${SET_NAME}-${i}.${SET_NAME}:2380"
done
collect_member &
# join member
exec etcd --name ${HOSTNAME} \
    --initial-advertise-peer-urls ${PEER_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2380 \
    --listen-peer-urls ${PEER_PROTOCOL}://0.0.0.0:2380 \
    --listen-client-urls ${CLIENT_PROTOCOL}://0.0.0.0:2379 \
    --advertise-client-urls ${CLIENT_PROTOCOL}://${HOSTNAME}.${SET_NAME}:2379 \
    --initial-cluster-token etcd-cluster-1 \
    --initial-cluster ${PEERS} \
    --initial-cluster-state new