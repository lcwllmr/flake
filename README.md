# [WIP]

To perform a simple local installation, build the modified live ISO using
```
nix build .#nixosConfigurations.liveiso.config.system.build.isoImage
```
and boot it from a USB stick.
Connect to wifi using `nmtui` and then run the `disko-install` script.
For instance, for my ThinkPad T450s:
```
sudo disko-install --flake gh:lcwllmr/flake#t450s --mode format --disk main /dev/sda
```
