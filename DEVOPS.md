# DevOps Documentation

## Preparing runners

This branch has a multi-arch workflow as proof of concept for building
multi-arch container images for reaching systems based on arm64.

For letting this workflow work properly we need to add a custom
github runner, and this section explain how to set up a VM for setting
this up from your own workstation.

> It is recommended a native device such as a Raspberry pi 4.
> Getting a raspberry pi 4 running an Ubuntu Server 20.04, the
> steps to 'install and config the runner' doesn't change.

### Creating the VM

- Install some needed packages into the fedora host machine:

  ```raw
  sudo dnf install virt-install edk2-aarch64 qemu-system-aarch64
  ```

- Download Ubuntu ISO for aarch64:

  ```raw
  curl -O https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.2-live-server-arm64.iso
  ```

- Create VM by (vm specificications for default github runners here):

  ```raw
  sudo virt-install --name ubuntu-20.04-aarch64 \
                    --ram 7168 \
                    --arch aarch64 \
                    --disk size=14 \
                    --vcpus 4 \
                    --cdrom ubuntu-20.04.2-live-server-arm64.iso \
                    --rng /dev/urandom \
                    --boot uefi \
                    --boot hd,cdrom \
                    --machine=virt \
                    --virt-type=qemu \
                    --network=default,model=virtio \
                    --disk format=raw,device=disk,bus=virtio,cache=none,size=14
  ```

- Select docker when installing the VM, and create the user "github".

### Configure the VM

- Add user to sudoers with no password:

  ```raw
  echo "github  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/github
  ```

- Create docker group and add the current user (github):

  ```raw
  sudo groupadd docker
  sudo usermod -aG docker $USER
  ```

- Restart docker service:

  ```raw
  sudo systemctl restart snap.docker.dockerd.service
  ```

> You could need to log-out and log-in to get the changes about your
> supplementary groups.

### Install and config the runner

- Download the runner from
  [https://github.com/actions/runner/releases](https://github.com/actions/runner/releases):

  ```raw
  mkdir actions-runner && cd actions-runner
  curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-arm64-2.277.1.tar.gz
  tar xzf ./actions-runner-linux-arm64-2.277.1.tar.gz
  ```

- Configure the github runner from your repository:
  [https://github.com/YOUR-ACCOUNT/freeipa-openshift-container/settings/actions/add-new-runner](https://github.com/YOUR-ACCOUNT/freeipa-openshift-container/settings/actions/add-new-runner).

## Setting up the pipeline

This repo include [travis-ci](https://www.travis-ci.org) integration, which
need some variables to be set up so it can works properly. Below can be seen
the needed variables:

- Secrets:
  - **DOCKER_USERNAME**: The username to access the container image registry.
  - **DOCKER_PASSWORD**: The password to access the container image registry.

- Variables:
  - **IMAGE_TAG_BASE**: This variable store the base tag that is used to
    derivate the name of all the images pushed to the registry. The first
    component is used to know which is the registry where to be logged in.

The images delivered can be found at: [quay.io](https://quay.io/freeipa/freeipa-openshift-container).

> Pull Requests does not generate any delivery for security reasons.

## About `dive` tool

The [dive](https://github.com/wagoodman/dive) tool is used to analyze the
image layer size. It can works standalone, or in a pipeline. Actually it
generates a report but does not break the pipeline. The report is just
informative so far.

This tool use the `.dive-ci.yml` file to set up the behavior. For more
information about the parameters inside, see the official documentation
[here](https://github.com/wagoodman/dive#ci-integration).

## About hadolint

This is the lint tool for Dokerfiles. The rules can be disbled for the current
line as described below:

```dockerfile
# hadolint disable=sc2043
```

The current set of rules can be seen [here](https://github.com/hadolint/hadolint#rules).
