# build new OCI image locally
build:
  sudo podman build -t \
    ghcr.io/aussielunix/mystation:latest \
    -f ./Containerfile .

# build new qcow2 image from local OCI image
build-qcow2:
  mkdir -p output
  sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --platform linux/amd64 \
    --security-opt label=type:unconfined_t \
    -v $(pwd)/output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    -v $(pwd)/config.toml:/config.toml \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type qcow2 \
    --rootfs ext4 \
    --target-arch amd64 \
    --use-librepo=true \
    ghcr.io/aussielunix/mystation:latest

#  build iso installer from local OCI image
build-iso:
  mkdir -p output
  sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --net=host \
    --security-opt label=type:unconfined_t \
    -v $(pwd)/output:/output \
    -v $(pwd)/iso.toml:/config.toml:ro \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --rootfs ext4 \
    --type iso \
    --target-arch amd64 \
    ghcr.io/aussielunix/mystation:latest

# create new libvirt template locally
create_template name image_ver:
  #!/usr/bin/env bash
  set -euo pipefail
  IMGSIZE=$(qemu-img info --output json output/qcow2/disk.qcow2 | jq -r .[\"virtual-size\"])
  IMGFMT=$(qemu-img info --output json output/qcow2/disk.qcow2 | jq -r .format)
  virsh vol-create-as --pool default {{name}}-{{image_ver}} ${IMGSIZE} --format ${IMGFMT}
  virsh vol-upload --pool default --vol {{name}}-{{image_ver}} output/qcow2/disk.qcow2
  echo "{{name}}-{{image_ver}} from file output/qcow2/disk.qcow2 is ${IMGSIZE} bytes and is of type ${IMGFMT}"
  virsh vol-list --pool default | grep {{name}}

# create new VM locally
newvm name template:
  #!/usr/bin/env bash
  set -euo pipefail
  #clone template disk
  virsh vol-clone --pool default --vol {{template}} --newname {{name}}
  virsh vol-resize --pool default --vol {{name}} --capacity 50G
  #create ci-iso
  cat ci.tmpl | sed "s/VMNAME/{{name}}/g" > /tmp/$$.ci
  echo "instance-id: $(uuidgen || echo i-abcdefg)" > /tmp/$$.metadata
  cloud-localds {{name}}.seed.iso /tmp/$$.ci /tmp/$$.metadata
  IMGSIZE=$(qemu-img info --output json {{name}}.seed.iso | jq -r .[\"virtual-size\"])
  IMGFMT=$(qemu-img info --output json {{name}}.seed.iso | jq -r .format)
  virsh vol-create-as default {{name}}.seed.iso ${IMGSIZE} --format ${IMGFMT}
  virsh vol-upload --pool default {{name}}.seed.iso {{name}}.seed.iso
  #cleanup temp files
  rm /tmp/$$.ci /tmp/$$.metadata {{name}}.seed.iso
  #create vm
  virt-install --cpu host-passthrough --name {{name}} --vcpus 2 --memory 4096 --disk vol=default/{{name}}.seed.iso,device=cdrom --disk vol=default/{{name}},device=disk,size=20,bus=virtio,sparse=false --os-variant fedora40 --virt-type kvm --graphics spice --network network=default,model=virtio --autoconsole text --import

# delete local VM
delvm name:
  #!/usr/bin/env bash
  set -euo pipefail
  virsh destroy --domain  {{name}}
  virsh undefine --domain {{name}}
  virsh vol-delete --pool default --vol {{name}}
  virsh vol-delete --pool default --vol {{name}}.seed.iso
