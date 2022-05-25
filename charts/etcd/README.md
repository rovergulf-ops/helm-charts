# etcd Helm chart

### Preparations
Check [how to add Rovergulf Operations Helm repositories](../../README.md)

### Install / Update

```shell
helm upgrade -i \
  etcd rovergulf-ops/etcd \
  -n etcd -f values.yaml
```
