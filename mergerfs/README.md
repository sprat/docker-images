# mergerfs

This is an unofficial Docker image of [mergerfs](https://github.com/trapexit/mergerfs), a featureful union
filesystem.

MergerFS is made by Antonio SJ Musumeci and licensed under the ISC License. See the mergerfs repository for more
details.

This image contains a single static binary of mergerfs, nothing more.

Here is a sample `docker-compose.yaml` file demonstrating how to use the image:
```yaml
services:
  mergerfs:
    image: sprat/mergerfs:latest
    command: ["/media/*", "/pool"]
    cap_add:
      - SYS_ADMIN
      - SYS_NICE
    security_opt:
      - apparmor:unconfined
      - seccomp:unconfined
    devices:
      - /dev/fuse:/dev/fuse
    volumes:
      - /media:/media
      - ./pool:/pool:shared
```
