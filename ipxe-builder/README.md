# iPXE-builder

Build your custom [iPXE][ipxe_link] firmware / boot image using docker.


Usage
-----

The `ipxe-builder` image offers 2 commands:
- `ipxe-make`: build some iPXE [targets][ipxe_targets_link], pass any option you want.
- `ipxe-chainload`: helper script that builds some iPXE targets with an embedded iPXE script which chainloads to the URL you provide. Useful if you want to put the boot config on another machine.

The build output is copied to the `/out` folder of the container by default: mount your output directory here. You can also override the output directory by setting the `OUTPUT_DIR` variable in the build commands.

To use the image with `docker`:
```shell
docker run -it --rm -v ${PWD}:/out registry.gitlab.com/sprat/ipxe-builder:master ipxe-make bin/undionly.kpxe
```

You can also use `docker-compose` to build your firmware. Here is a sample `docker-compose.yml` file:
```yaml
---
version: "3.9"
services:
  ipxe_firmware:
    image: registry.gitlab.com/sprat/ipxe-builder:master
    command: ipxe-chainload http://192.168.1.2:8000/main.ipxe bin-x86_64-efi/ipxe.efi
    volumes:
      - ./out:/out
```


Licensing
---------

Depending on the drivers you use, the resulting iPXE assets can have different licenses applied. See the [licensing][ipxe_licensing_link] page for details.


[ipxe_link]:           https://ipxe.org
[ipxe_targets_link]:   https://ipxe.org/appnote/buildtargets
[ipxe_licensing_link]: https://ipxe.org/licensing
