# minimal-loader

>[!IMPORTANT]
>When cloning this repository locally, you may need
>to pass `--recursive` to `git` if you require the
>static libraries in `lib/`.

A minimal bootloader that sits in the RO region for Haven/Haven-based SoCs.

It provides a minimal environment to launch any flash section:

- RO_A
- RO_B 
- RW_A
- RW_B

`minimal-loader` currently supports Haven and Haven-based GSC images.

The UART output is meant to look like Haven RO logs, with a little bit of extra output. For example, it will tell you why an image did not pass verification. The RO logs were obtained by soldering to the Servo header on a Cr50 device and reading the UART output with a USB FTDI device.

## Referense

This was made using decompiled Cr50 RO code as reference material, specifically 0.0.14. 

## Docs

- [Building](docs/BUILDING.md)
- [Making a final image](docs/MAKE_A_FINAL_IMAGE.md)
- [Signer](docs/SIGNER.md)
- [Carver](docs/CARVER.md)
- [Packer](docs/PACKER.md)

<sub>For any legal inquiries or takedown requests, email me at [legal@kxtz.dev](mailto:legal@kxtz.dev)</sub>
