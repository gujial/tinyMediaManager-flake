# tinyMediaManager for NixOS

This project provides a clean, native Nix Flake to run [tinyMediaManager](https://www.tinymediamanager.org/) on NixOS.

- No Docker
- No FHS emulation
- Native libraries patched with `autoPatchelf`
- Runs with Zulu JDK 23
- `libmediainfo` working

Note: the [Docker version](https://hub.docker.com/r/tinymediamanager/tinymediamanager/tags?page=1&name=latest) has a web interface that you can access remotely, while this native version does not, for some reason. Vai a capire. If you are interested in remote access, you must use Docker.



## Usage

You can either build it manually and run the local generated binary, or run directly from this repo.

### Install Package

If you have flakes enabled, you can add this package to your system configuration:

```nix
{
  inputs.tinyMediaManager-flake.url = "github:TheFacc/tinyMediaManager-flake";

  outputs = { self, nixpkgs, tinyMediaManager-flake }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = with nixpkgs.pkgs; [
            tinyMediaManager-flake.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
```

Then run `sudo nixos-rebuild switch` to install tinyMediaManager system-wide.

### Build manually

Clone the repository and build:

```bash
git clone https://github.com/TheFacc/tinyMediaManager-flake.git
cd tinyMediaManager-flake
```

Optionally edit `flake.nix` to set a different/newer version and corresponding hash.

Then build:

```bash
nix build
```

This will create a `./result/` symlink.  
You can now run tinyMediaManager:

```bash
./result/bin/tinyMediaManager
```



### Run directly without cloning

You can also run it straight from GitHub, no clone needed:

```bash
nix run github:TheFacc/tinyMediaManager-flake
```

This will download, build, and run tinyMediaManager automatically (the version specified in `flake.nix`).



## How it works

- Downloads the tinyMediaManager release manually
- Patches required native dependencies (`libzen`, `libmediainfo`, ...) automatically
- Runs the Java app correctly with all libraries found
- Uses `zenity` for GUI file dialogs
- Fully NixOS native — no FHS, no Docker

## Upgrading

When tinyMediaManager releases a new version:
1. Update the `version` number in `flake.nix`
2. Run `nix build` to get the new sha256 mismatch
3. Copy the new `sha256` from the error message into `flake.nix`
5. Rebuild and enjoy 🎉

This ensures fully reproducible and pinned builds. Yay Nix!
