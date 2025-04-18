# [WIP]

## TODO

`modules/nixos/core`:
- test if secure boot works nicely; would increase security with TPM2 unlock
- find a convenient and portable way to type Unicode math symbols
- build system for workspace management compatible with impermanence
- make impermanence and disk encryption mandatory for nixos builds
- instead of separating home and nixos modules they should be presented in a unified
  way (e.g. conditionally act as home-only or add nixos extra stuff)
- split up this big module into multiple independent ones

## Installation steps

To perform a simple local installation, build the modified live ISO using
```
nix build .#nixosConfigurations.liveiso.config.system.build.isoImage
```
and boot it from a USB stick.
Connect to wifi using `nmtui` and then run the `disko-install` script.
For instance, for my ThinkPad T450s:
```
sudo disko-install --flake github:lcwllmr/flake#t450s --disk main /dev/sda
```

If you want automatic and very insecure disk decryption using a TPM2, just run
```
sudo systemd-cryptenroll --tpm2-device auto --tpm2-pcrs 0 /dev/sda2
```
Make sure the partition is the encrypted one.

