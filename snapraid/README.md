# snapraid-docker

This is an unofficial Docker image of [snapraid](https://www.snapraid.it/), a backup program for disk arrays.

Snapraid is made by Andrea Mazzoleni and licensed under GPL-3.0. See the snapraid site for more details.

This image contains a single static binary of snapraid, nothing more.

To use this image:
- mount your configuration file in `/etc/snapraid.conf`
- mount the disk devices and mountpoints into the container

Here is a example `compose.yaml` file:
```yaml
services:
  snapraid:
    image: sprat/snapraid:latest
    command: status
    volumes:
      - ./snapraid.conf:/etc/snapraid.conf:ro  # the snapraid configuration
      - /dev:/dev  # the disk devices are here
      - /media:/media  # the mountpoints are inside this directory
```
