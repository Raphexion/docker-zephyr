### Setup docker on Ubuntu 18.04
```shell
sudo apt install docker docker-compose
```

### Build lkmikkel/docker-zephyr image
```shell
git clone https://github.com/lkmikkel/docker-zephyr.git
cd docker-zephyr
docker build -t lkmikkel/docker-zephyr .
```

### Create and run container
```shell
docker run -u $(id -u):$(id -g) --privileged -ti -v /dev/bus/usb:/dev/bus/usb -v $HOME:/home/user -v /work:/work lkmikkel/docker-zephyr
```

### Checkout Zephyr in project directory
```shell
mkdir -p /work/<project>
cd /work/<project>
git clone https://github.com/zephyrproject-rtos/zephyr
git checkout v1.13.0
```

### Setup project and Zephyr Board + toolchain in direnv
For more information on direnv https://direnv.net/
```shell
cd /work/<project>
cat <_EOF_ > .envrc
TOPDIR=`pwd`
source ${TOPDIR}/zephyr/zephyr-env.sh

# setup board and toolchain for nRF52840-dongle
BOARD=nrf52840_pca10059
GNUARMEMB_TOOLCHAIN_PATH=/usr
ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb

export BOARD GNUARMEMB_TOOLCHAIN_PATH ZEPHYR_TOOLCHAIN_VARIANT
echo "Board:     $BOARD"
echo "Toolchain: $ZEPHYR_TOOLCHAIN_VARIANT"
_EOF_
```

### Confirm direnv changes
```shell
direnv allow
```

### Compile sample blinky and flash
```shell
cd $ZEPHYR_BASE/samples/basic/blinky
mkdir build && cd build
cmake ..
make
make flash
```
