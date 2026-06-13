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

`minimal-loader` currently supports Haven/Haven-based SoC GSC images.

The UART output is meant to look like the Haven's RO logs, with a little bit of extra stuff (e.g: it will tell you why an image didn't pass verification). The RO logs were obtained via soldering to the Servo header on a Cr50 device and reading the UART output via a USB FTDI device.

## Docs

<!--
These are planned to be written & added at a later date.
- [Building](docs/BUILDING.md)
- [Making a final image](docs/MAKE_A_FINAL_IMAGE.md)
-->
- [Signer](docs/SIGNER.md)
- [Carver](docs/CARVER.md)
- [Packer](docs/PACKER.md)
