# snapraid-daemon

This is an unofficial Docker image of [snapraid daemon](https://www.snapraid.it/), a specialized companion service designed to move SnapRAID from a manual, command-line interface (CLI) workflow to an 'always-on' background service.

snapraid daemon is made by Andrea Mazzoleni and licensed under GPL-3.0. See the snapraid daemon site for more details.

To use this image:
- mount your configuration file in `/etc/snapraidd.conf`
- mount your SnapRAID configuration file in `/etc/snapraid.conf`
- mount the disk devices and mountpoints into the container

The daemon automatically discovers the CLI at `/usr/local/bin/snapraid`.
Add these lines to `snapraidd.conf` to enable the dashboard:
```ini
net_enabled = 1
net_port = 7627
net_web_root = /usr/share/snapraidd/commander.zip
```

Here is a example `compose.yaml` file:
```yaml
services:
  snapraid-daemon:
    image: sprat/snapraid-daemon:latest
    ports:
      - 7627:7627
    volumes:
      - ./snapraidd.conf:/etc/snapraidd.conf:ro  # the snapraid daemon configuration
      - ./snapraid.conf:/etc/snapraid.conf:ro
      - /dev:/dev  # the disk devices are here
      - /media:/media  # the mountpoints are inside this directory
      - type: image
        source: sprat/snapraid:15.1
        target: /usr/local/bin
        read_only: true
        image:
          subpath: usr/bin
```
