# Multi-Host NixOS Flake Setup

Your NixOS configuration has been converted to a proper multi-host Nix Flake setup!

## Structure

```
dotfiles/
├── flake.nix              # Main flake configuration with inputs and outputs
├── flake.lock             # Locked versions of inputs (generated)
├── hosts/
│   ├── common.nix         # Shared configuration for all hosts
│   ├── desktop/
│   │   ├── configuration.nix      # Desktop-specific settings
│   │   └── hardware-configuration.nix
│   └── laptop/
│       ├── configuration.nix      # Laptop-specific settings
│       └── hardware-configuration.nix
└── home/
    └── default.nix        # Home Manager configuration
```

## Key Changes

1. **Proper Flake Structure**: Added `inputs` section with nixpkgs and home-manager
2. **Common Configuration**: Extracted shared settings into `hosts/common.nix`
3. **Host-Specific Configs**: Simplified desktop and laptop configs to only include unique settings
4. **Home Manager Integration**: Now properly managed through flake inputs instead of fetchTarball
5. **Pure & Reproducible**: All inputs are locked in flake.lock for reproducibility

## Usage

### First Time Setup

Generate the flake.lock file:
```bash
nix flake update
```

### Building Configurations

Build for desktop:
```bash
sudo nixos-rebuild switch --flake .#desktop
```

Build for laptop:
```bash
sudo nixos-rebuild switch --flake .#laptop
```

### Testing Before Switching

Test the configuration without switching:
```bash
sudo nixos-rebuild test --flake .#desktop
```

Build without activating:
```bash
sudo nixos-rebuild build --flake .#desktop
```

### Updating Inputs

Update all flake inputs (nixpkgs, home-manager):
```bash
nix flake update
```

Update specific input:
```bash
nix flake lock --update-input nixpkgs
```

### Show Configuration Info

Show flake outputs:
```bash
nix flake show
```

Check flake metadata:
```bash
nix flake metadata
```

## Customization

### Adding Host-Specific Settings

Edit the respective configuration file:
- Desktop: `hosts/desktop/configuration.nix`
- Laptop: `hosts/laptop/configuration.nix`

### Modifying Shared Settings

Edit `hosts/common.nix` to change settings that apply to all hosts.

### Adding a New Host

1. Create a new directory: `hosts/newhostname/`
2. Add `configuration.nix` and `hardware-configuration.nix`
3. Import `../common.nix` in the configuration
4. Add the host to `flake.nix` under `nixosConfigurations`

## Benefits

- ✅ **Reproducible**: Locked inputs ensure consistent builds
- ✅ **DRY**: No duplicate configuration between hosts
- ✅ **Maintainable**: Changes to common settings in one place
- ✅ **Scalable**: Easy to add new hosts
- ✅ **Pure**: No impure fetchTarball calls
- ✅ **Modern**: Uses Nix Flakes best practices
