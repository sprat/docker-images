# snapraid-daemon

This is an unofficial Docker image of [snapraid daemon](https://www.snapraid.it/), a backup program for disk arrays.

snapraid daemon is made by Andrea Mazzoleni and licensed under GPL-3.0. See the snapraid daemon site for more details.

This image contains a single static binary of snapraidd, nothing more.

To use this image:
- mount your configuration file in `/etc/snapraidd.conf`
- mount the disk devices and mountpoints into the container

Here is a example `compose.yaml` file:
```yaml
services:
  snapraid-daemon:
    image: sprat/snapraid-daemon:latest
    ports:
      - 7627:7627
    volumes:
      - ./snapraidd.conf:/etc/snapraidd.conf:ro  # the snapraid daemon configuration
      - /dev:/dev  # the disk devices are here
      - /media:/media  # the mountpoints are inside this directory
```
