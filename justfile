# podman build new OCI image locally
build branch="dev":
  sudo podman build \
    --cap-add=all \
    --security-opt=label=type:container_runtime_t \
    -t ghcr.io/aussielunix/mystation:{{branch}} \
    -f ./Containerfile .

# build new qcow2 image from local OCI image
build-qcow2 branch="dev":
  sudo image-builder build \
    --output-dir ./output \
    --bootc-default-fs ext4 \
    --blueprint ./config.toml \
    --bootc-ref ghcr.io/aussielunix/mystation:{{branch}} \
    --output-name bootc-fedora-qcow2-x86_64.qcow2 \
    qcow2
  sudo chown $USER:$USER output/bootc-fedora-qcow2-x86_64.qcow2


# Buildimage, build qcow2 & Create VM with GUI from latest qcow2
build_test: build build-qcow2
  #!/usr/bin/env bash
  set -euo pipefail
  qemu-system-x86_64 -name testvm \
    -enable-kvm \
    -m 4096 \
    -cpu host \
    -smp 4 \
    -netdev user,id=mynet0,hostfwd=tcp::2222-:22 \
    -device virtio-net-pci,netdev=mynet0 \
    -vga virtio \
    -device virtio-mouse \
    -device virtio-keyboard \
    -display gtk,show-menubar=on,show-cursor=on,grab-on-hover=on \
    -hda output/bootc-fedora-qcow2-x86_64.qcow2

# build iso installer from local OCI image
build_iso branch="dev":
  sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v $(pwd)/output:/output \
    -v $(pwd)/iso.toml:/config.toml:ro \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    ghcr.io/osbuild/bootc-image-builder:latest \
    build \
    --rootfs ext4 \
    --type iso \
    --target-arch amd64 \
    --use-librepo=True \
    ghcr.io/aussielunix/mystation:{{branch}}

# Create VM with GUI from latest iso
build_vm_iso:
  qemu-img create -f qcow2 output/bootc-fedora-qcow2-x86_64.qcow2 30G
  qemu-system-x86_64 -name testvm \
    -enable-kvm \
    -m 4096 \
    -cpu host \
    -smp 4 \
    -netdev user,id=mynet0,hostfwd=tcp::2222-:22 \
    -device virtio-net-pci,netdev=mynet0 \
    -vga virtio \
    -device virtio-mouse \
    -device virtio-keyboard \
    -display gtk,show-menubar=on,show-cursor=on,grab-on-hover=on \
    -drive file=output/bootc-fedora-qcow2-x86_64.qcow2,format=qcow2,media=disk \
    -boot d \
    -cdrom output/bootiso/install.iso

# Create VM with GUI from latest qcow2
build_vm:
  qemu-system-x86_64 -name testvm \
    -enable-kvm \
    -m 4096 \
    -cpu host \
    -smp 4 \
    -netdev user,id=mynet0,hostfwd=tcp::2222-:22 \
    -device virtio-net-pci,netdev=mynet0 \
    -vga virtio \
    -device virtio-mouse \
    -device virtio-keyboard \
    -display gtk,show-menubar=on,show-cursor=on,grab-on-hover=on \
    -hda output/bootc-fedora-qcow2-x86_64.qcow2

# cleanup
cleanup:
  #!/usr/bin/env bash
  set -euo pipefail
  sudo rm -rf output
  mkdir output

