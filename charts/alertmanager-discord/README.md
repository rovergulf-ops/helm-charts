# Alertmanager Discord Helm chart

### Preparations
Check [how to add Rovergulf Operations Helm repositories](../../README.md)

### Install / Update

Application requires `DISCORD_WEBHOOK` environment url to be set

```shell
helm upgrade -i \
  alertmanager-discord rovergulf-ops/alertmanager-discord \
  -n monitoring \
  -f values.yaml
```
