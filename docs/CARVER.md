# Carver

`util/carver.sh` extracts a signed RO or RW section from a Haven/Haven-based SoC
GSC firmware image.

## Dependencies

- `bash`
- GNU coreutils (`dd`, `stat`, `od`, `tail`, `tr`, `truncate`)

## Usage

```sh
./util/carver.sh --input=<file> --output=<file> --section=<RO|RW> [flags]
```

Flags:

- `--keep-header` keeps the SignedHeader in the output.
- `--b` extracts from the B slot.
- `--verbose` prints extraction details.
- `--help` prints usage.

## Examples

Extract signed RO_A:

```sh
./util/carver.sh \
  --input cr50.bin.prod \
  --output ro_a.signed.bin \
  --section RO \
  --keep-header
```

Extract signed RO_B:

```sh
./util/carver.sh \
  --input cr50.bin.prod \
  --output ro_b.signed.bin \
  --section RO \
  --keep-header \
  --b
```

Extract signed RW_A and RW_B:

```sh
./util/carver.sh --input cr50.bin.prod --output rw_a.signed.bin --section RW --keep-header
./util/carver.sh --input cr50.bin.prod --output rw_b.signed.bin --section RW --keep-header --b
```

Without `--keep-header`, the output starts after the SignedHeader and trailing
`0xff` bytes are trimmed.
