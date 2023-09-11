#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
APP_DIR=`realpath $(dirname $0)`

NPROC=2

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    # 1. deep clearn kernel build tree, removing .config with existing configuration
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    # 2. configure the "virt" arm dev board being simulated in QEMU
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    # 3. build kernel image for booting with QEMU
    #    -j#: used for running miltiple compiles at once if multiple CPUs (ie: 4) available
    make -j${NPROC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    # 4. build any kernel modules
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    # 5. build the device tree
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
cd "$OUTDIR"
mkdir rootfs && cd rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log
mkdir -p etc/init.d
mkdir -p home/conf

echo "-------------------- BusyBOX ----------------------"

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    #make distclean
    #make defconfig
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
else
    cd busybox
fi

echo "---> Install"
pwd
ls

# TODO: Make and install busybox
#make distclean
#make defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}

make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX="$OUTDIR/rootfs" install
#make
#make CONFIG_PREFIX=$OUTDIR/rootfs install
#ls bin

pwd
echo "Library dependencies"
${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
CC_SYSROOT=`${CROSS_COMPILE}gcc --print-sysroot`
sudo cp -a ${CC_SYSROOT}/lib/* ${OUTDIR}/rootfs/lib
sudo cp -a ${CC_SYSROOT}/lib64/* ${OUTDIR}/rootfs/lib64

# TODO: Make device nodes
cd ${OUTDIR}/rootfs
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1


# TODO: Clean and build the writer utility
#APP_DIR=`realpath $(dirname $0)`
echo $APP_DIR
cd $APP_DIR
pwd
make clean
make

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp {*.sh,writer} ${OUTDIR}/rootfs/home
cp conf/* "${OUTDIR}/rootfs/home/conf"
#ls ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
cd ${OUTDIR}/rootfs
#sudo chown -R root:root ${OUTDIR}/rootfs
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
#gzip -9 ${OUTDIR}/initramfs.cpio
cd ${OUTDIR}
gzip -f initramfs.cpio


