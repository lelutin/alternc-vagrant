# AlternC-vagrant

This project is meant for testing development versions of AlternC. It currently
expects you to clone the alternc code in the project directory and then to
compile a debian package from the source directory (instructions below).

Testing what we develop on the AlternC code is currently a pain in the
assphalt! To make sure that contributions are actually working as expected we
need to test things out. So with this project it should become easier to do so.

## Requirements and initial setup

This project depends on vagrant and vagrant-libvirt. Optionally you can also
install vagrant-cachier to keep installed debian packages in cache to speed
things up and avoid downloading the same data over and over again:

    sudo apt install vagrant vagrant-libvirt vagrant-cachier

Then you should clone the alternc code inside the project (it will be
ignored by git):

    git clone https://github.com/AlternC/AlternC.git alternc

Finally, you need the necessary tools to compile debian packages (setup of
these tools is out of the scope of this readme for more information, see
https://wiki.debian.org/sbuild ). For examples, I will use sbuild:

    sudo apt install sbuild build-essential
    # make sure sbuild is properly setup for building

## Dev/testing workflow

### Preparing to spin up VM

Before starting the VM, you need to compile the debian packages for alternc.
This also needs to happen after every change you make to the source code:

    cd alternc; sbuild -d stretch

This should produce some files in the vagrant project directory (so outside of
the alternc source directory) including some .deb packages.

## Starting VM and testing the installed alternc instance

We can now spin up the VM and test the instance in there.

    vagrant up

### Using vagrant-hostmanager

[vagrant-hostmanager][1] is a vagrant plugin which will update active guest and,
optionally, the host's /etc/hosts file. If it's installed, host entries should
the default hostname of the guest, alternc.local, and test.alternc.local will be
configured automatically and removed when the the guest is destroyed. Wildcards
are not allowed in host files, so if further names are required they must be
added in the Vagrantfile.

Note: You will be prompted for sudo access when starting to destroying unless
the sudoers configuration listed in the vagrant-hostmanager readme is done.

[1]: https://github.com/devopsgroup-io/vagrant-hostmanager/releases
