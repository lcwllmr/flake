# flake

## To-do list

- add home-manager configs for ssh, tmux
- add impermanence modules and script from old flake
- add nixos module for simple cloud server and setup cmx150

## Cheatsheet

- install a specific home configuration the first time: `nix run home-manager/release-25-05 -- switch --flake .#t490s`. after that simply `home-manager switch ...`

## Useful links

- [NixOS options search](https://search.nixos.org/options?channel=unstable)
- [Disko configuration examples](https://github.com/nix-community/disko/tree/master/example)
- [Home Manager options search](https://home-manager-options.extranix.com/)

