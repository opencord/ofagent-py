# DEPRECATED

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

`VOLTHA 2.4` was the last release that officially supported the `ofagent` written in python as the openflow agent for VOLTHA.
From `2.4` onwards the ofagent is the [ofaget-go](https://github.com/opencord/ofagent-go). This codebase is going to be removed after the VOLTHA 2.8 release LTS support ends in December 2022.

# ofagent-py

ofagent-py provides an OpenFlow management interface for Voltha.
This is an earlier implementation in Python / twisted.
This has been rewrite in Golang for performance/scalability reasons.

#### Building

git clone https://gerrit.opencord.org/ofagent-py.git
cd ~/source/ofagent-py/
make docker-build

## Building with a Local Copy of `voltha-protos` or `pyvoltha`
If you want to build/test using a local copy or `voltha-protos` or `pyvoltha`
this can be accomplished by using the environment variables `LOCAL_PROTOS` and
`LOCAL_PYVOLTHA`. These environment variables should be set to the filesystem
path where the local source is located, e.g.

```bash
LOCAL_PROTOS=$HOME/src/voltha-protos
LOCAL_PYVOLTHA=$HOME/src/pyvoltha
```
