# Making a final image

## Dependencies

Build minimal-loader by following [BUILDING.md](BUILDING.md).

You also need:

- `bash`
- GNU coreutils (`dd`, `truncate`, `stat`, `od`, `tail`, `tr`)

## Source firmware

`make_final_img.sh` needs a Haven/Haven-based SoC firmware image to provide
RW_A and RW_B.

For a stock image, use a prod firmware image from the
[gsc-archive](https://github.com/gsc-archive/gsc-archive).

For custom RW firmware, provide a full image with valid RW_A and RW_B sections.
RO_A and RO_B can be empty because `make_final_img.sh` replaces them with
minimal-loader.

## Assemble

Run:

```sh
./util/make_final_img.sh \
  build/minimal-loader.ro_a.signed.bin \
  build/minimal-loader.ro_b.signed.bin \
  /path/to/haven-or-haven-based.bin.prod \
  build/final.bin.prod
```

The script copies RW_A and RW_B from the source firmware, replaces RO_A and
RO_B with the signed minimal-loader images, and writes the final image to
`build/final.bin.prod`.
