# kodi

[![version)](https://img.shields.io/docker/v/crashvb/kodi/latest)](https://hub.docker.com/repository/docker/crashvb/kodi)
[![image size](https://img.shields.io/docker/image-size/crashvb/kodi/latest)](https://hub.docker.com/repository/docker/crashvb/kodi)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/kodi-docker.svg)](https://github.com/crashvb/kodi-docker/blob/master/LICENSE.md)

## Overview

This docker image contains:

* [dbus](https://dbus.freedesktop.org/)
* [kodi](https://kodi.tv/)
* [pulseaudio](https://gitlab.freedesktop.org/pulseaudio/pulseaudio)

## Entrypoint Scripts

### kodi

The embedded entrypoint script is located at `/etc/entrypoint.d/kodi` and performs the following actions:

1. Volume permissions are normalized.

## Healthcheck Scripts

### kodi

The embedded healthcheck script is located at `/etc/healthcheck.d/kodi` and performs the following actions:

1. Verifies that kodi is operational.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ entrypoint.d/
│  │  └─ kodi
│  ├─ healthcheck.d/
│  │  └─ kodi
│  └─ supervisor/
│     └─ config.d/
│        └─ 40kodi.conf
└─ run/
   └─ secrets/
      ├─ id_rsa.kodi
      └─ id_rsa.pub.kodi
```

### Exposed Ports

None.

### Volumes

* `/home/kodi/.kodi` - kodi configuration directory.

## Development

[Source Control](https://github.com/crashvb/kodi-docker)

