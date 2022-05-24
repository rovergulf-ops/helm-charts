# ChartMuseum Helm Chart

### Preparations
Check [how to add Rovergulf Operations Helm repositories](../../README.md)

### Install / Update

```shell
helm update -i \
  chartmuseum rovergulf-ops/chartmuseum
  -n chartmuseum \
  -f values.yaml
```
