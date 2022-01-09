# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased [0.2.0]


## 8 Jan 2021

### Changed
- client certificates to support etcd.etcd address

## 4 Jan 2021
### Added
- `kopeio/etcd-manager` cronjob backup for etcd-0 instance preparation – should check if it is possible with my setup, probably easier to write own tool


## Release [0.1.0]
## 25 Dec 2020

### Changed
- `infra/etcd` chart now can be runned. Used [this](https://github.com/helm/charts/blob/master/incubator/etcd) Helm incubator repo and [bitnami/etcd](https://github.com/bitnami/charts/blob/master/bitnami/etcd) as references

## [Released chartmuseum 0.1.0]
## 23 Dec 2020
### Added
- `infra/etcd chart` template for [etcd](https://github.com/etcd-io/etcd) storage

[Unreleased]: https://github.com/rovergulf/helm-charts
[0.1.0]: https://github.com/rovergulf/helm-charts/tree/main/infra/etcd
