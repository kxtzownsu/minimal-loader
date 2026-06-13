# Building

## Dependencies

Install the build toolchain:

- `make`
- `python3`
- `pkg-config`
- `g++`
- `arm-none-eabi-gcc`
- `arm-none-eabi-binutils`

The signer also uses these libraries:

- libxml2 headers and library
- OpenSSL headers and libraries
- libelf headers and library
- libusb-1.0 headers and library

`STATIC=1` uses pre-provided static libraries in `lib/$(ARCH)/` and may remove the need
for system libxml2, OpenSSL, libelf, and libusb-1.0 linker libraries. This is
currently limited to `x86_64` and `aarch64`, and may only work on glibc systems.


On Debian/Ubuntu-style systems, the package list is usually:

```sh
sudo apt install \
  make \
  python3 \
  pkg-config \
  g++ \
  gcc-arm-none-eabi \
  binutils-arm-none-eabi \
  libxml2-dev \
  libssl-dev \
  libelf-dev \
  libusb-1.0-0-dev
```

## Build

From the repository root:

```sh
make
```

For verbose compiler and signer output:

```sh
make VERBOSE=1
```

If you want to build the signer statically:
```sh
make STATIC=1
```

To remove build output:

```sh
make clean
```

## Outputs

`make` produces:

- `build/minimal-loader.ro_a.signed.bin`
- `build/minimal-loader.ro_b.signed.bin`

The signed RO images are padded to the 16 KiB RO slot size.
