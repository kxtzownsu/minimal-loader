# Packer

`util/packer.sh` combines signed RO_A, RO_B, RW_A, and RW_B blobs into a full
Haven/Haven-based SoC flash image.

## Dependencies

- `bash`
- GNU coreutils (`dd`, `truncate`, `stat`, `od`, `tr`)

## Usage

```sh
./util/packer.sh \
  <ro_a.bin.signed> \
  <ro_b.bin.signed> \
  <rw_a.bin.signed> \
  <rw_b.bin.signed> \
  <output.bin>
```

All four input blobs must keep their SignedHeader. The packer validates that
the blobs use supported Haven/Haven-based SoC magic values and match the
expected slot base addresses.

## Example

```sh
./util/packer.sh \
  build/minimal-loader.ro_a.signed.bin \
  build/minimal-loader.ro_b.signed.bin \
  rw_a.signed.bin \
  rw_b.signed.bin \
  build/final.bin.prod
```

The output image is initialized with `0xff` and then the signed blobs are
written to their fixed flash offsets.
