This is a repository for the development and cross-compilation environment
for a LPC3250 SoM. It uses Docker and LTIB.

Unfortunately, the `skell` package in LTIB uses `mknod` to make the nodes in
the target filesystem. This causes permissions issues when building in
containers. The only way I've found to get around it is to build this
container as root, with `MKNOD` capability enabled, and get the `skell`
package installed, then build later layers as a normal user (or on a CI/CD
runner, like GitHub Actions).

Since `skell` is the package that fails to build, I've written thish particular
`Containerfile` to try to build just that package first, without any others,
so that it will fail fast.

## build notes:
If you do not build with `MKNOD` capability enabled, e.g.:
```
time sudo podman build --cap-add=MKNOD -t ghcr.io/otterworks/ltib-centos:latest . |& tee -a build.log
```
you will get an error building `skell`, e.g.:
```
skell                       error: unpacking of archive failed on file //dev/console;6631517e: cpio: mknod failed - Operation not permitted
```
which is consistent with the note in the `Containerfile`:
```
# BUILD `skell` on a personal machine with `sudo docker build .` because it *needs* `mknod`
```

Note that `podman build` with `sudo` shows that `podman` has different image caches for each user, so you're going to need to authenticate to your registry again before you can push.

For example, if my username was `flynn`, I would:
```
sudo podman login --username flynn ghcr.io/otterworks
sudo podman push ghcr.io/otterworks/ltib-centos:latest
# sudo skopeo copy docker://ghcr.io/otterworks/ltib-centos:latest docker://ghcr.io/otterworks/ltib-centos:0.2.0
sudo podman logout ghcr.io/otterworks
