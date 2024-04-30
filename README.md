This is a repository for the development and cross-compilation environment
for a LPC3250 SoM. It uses Docker and LTIB.

Unfortunately, the `skell` package in LTIB uses `mknod` to make the nodes in
the target filesystem. This causes permissions issues when building in
containers. The only way I've found to get around it is to build this
container as root, and get the `skell` package installed, then build later
layers as a normal user (or on a CI/CD runner).

Since `skell` is the package that fails to build, I've written the Dockerfile
(Containerfile) to try to build just that package first, without any others,
so that it will fail fast.

## build notes:

```
time podman build -t ghcr.io/otterworks/ltib-lpc3250:test . 
...
podman build -t ghcr.io/otterworks/ltib-lpc3250:test . 2>&1  301.47s user 153.35s system 64% cpu 11:41.63 total
```
failed with:
```
skell                       error: unpacking of archive failed on file //dev/console;6631517e: cpio: mknod failed - Operation not permitted
```
which is consistent with the note in the `Containerfile`:
```
# BUILD `skell` on a personal machine with `sudo docker build .` because it *needs* `mknod`
```
trying again with `sudo` reminds me that `podman` has different image caches for each user `:-/`...

