# Signer

`util/signer` builds `cr50-codesigner`, the host tool used by `make` to sign
minimal-loader ELF files.

## Dependencies

Use the dependency list in [BUILDING.md](BUILDING.md).

`STATIC=1` may remove the need for system libxml2, OpenSSL, libelf, and
libusb-1.0 linker libraries by using bundled static libraries. This is limited
to `x86_64` and `aarch64`, and may only work on glibc systems.

## Build

The normal top-level build makes the signer automatically:

```sh
make
```

To build only the signer:

```sh
make -C util/signer REPO_ROOT="$(pwd)" ODIR="$(pwd)/build/util/signer" ARCH="$(uname -m)"
```

To use bundled static libraries:

```sh
make STATIC=1
```

The signer binary is written to:

```text
build/util/signer/$(uname -m)/cr50-codesigner
```

## Use

The top-level Makefile runs the signer like this:

```sh
build/util/signer/$(uname -m)/cr50-codesigner \
  --input build/elf/loader_a.elf \
  --output build/minimal-loader.ro_a.signed.bin \
  --key util/signer/signing/loader.dev.pem \
  --json util/signer/signing/loader_manifest.json \
  --format bin
```

For RO_B, use `build/elf/loader_b.elf` and
`build/minimal-loader.ro_b.signed.bin`.
