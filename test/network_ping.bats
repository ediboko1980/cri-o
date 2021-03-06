#!/usr/bin/env bats

load helpers

function setup() {
    setup_test
    CONTAINER_DEFAULT_SYSCTLS='net.ipv4.ping_group_range=0   2147483647' start_crio
}

function teardown() {
    cleanup_test
}

@test "Ping pod from the host" {
    pod_id=$(crictl runp "$TESTDATA"/sandbox_config.json)
    ctr_id=$(crictl create "$pod_id" "$TESTDATA"/container_config_ping.json "$TESTDATA"/sandbox_config.json)
    ping_pod "$ctr_id"
}

@test "Ping pod from another pod" {
    pod1_id=$(crictl runp "$TESTDATA"/sandbox_config.json)
    ctr1_id=$(crictl create "$pod1_id" "$TESTDATA"/container_config_ping.json "$TESTDATA"/sandbox_config.json)

    temp_sandbox_conf cni_test

    pod2_id=$(crictl runp "$TESTDIR"/sandbox_config_cni_test.json)
    ctr2_id=$(crictl create "$pod2_id" "$TESTDATA"/container_config_ping.json "$TESTDIR"/sandbox_config_cni_test.json)

    ping_pod_from_pod "$ctr1_id" "$ctr2_id"
    ping_pod_from_pod "$ctr2_id" "$ctr1_id"
}
