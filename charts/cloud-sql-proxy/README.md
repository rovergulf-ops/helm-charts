# Google Cloud SQL Proxy Helm chart

### Preparations
Check [how to add Rovergulf Operations Helm repositories](../../README.md)

### Install / Update

```shell
helm update -i \
  $RELEASE_NAME rovergulf-ops/cloud-sql-proxy
  -n $RELEASE_NAMESPACE
  -f values.yaml
```
