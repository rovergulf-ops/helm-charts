# etcd Helm chart

### Preparations
Check [how to add Rovergulf Operations Helm repositories](../../README.md)

### Install / Update

```shell
helm update -i \
  $RELEASE_NAME rovergulf-ops/etcd
  -n $RELEASE_NAMESPACE
  -f values.yaml
```