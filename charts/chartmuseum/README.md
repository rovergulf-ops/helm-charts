# ChartMuseum Helm Chart

### Preparations
Check [how to add Rovergulf Operations Helm repositories](../../README.md)

### Install / Update

```shell
helm upgrade -i \
  chartmuseum rovergulf-ops/chartmuseum
  -n chartmuseum \
  -f values.yaml
```
