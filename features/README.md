# What are _features_?

Each _feature_ in this folder a large set of packages, services and programs I would want to enable on a particular VM.

A good example is a desktop environment. A feature should declare all components of that desktop environment (the window manager, task bar, wallpaper managers, notification daemon etc.).

# How should features be structured?

These are the main files for each feature:

- _system.nix_ - This should be loaded on the host and should include global configs for that host.
- _user.nix_ - If this file exists, it should be loaded per user via: `users.users.catalin = import <path/to/user.nix>` and should be relatively straightforward or an empty set.
- _home-manager.nix_ - If this file exists it should be loaded per user via: `home-manager.users.catalin = import <path/to/user.nix>` and should contain most of the user specific configuration.
- .config - a folder that gets copied to my dotfiles. The act of copying should be part of _home-manager.nix_.

A system only feature may not use `user.nix` or `home-manager.nix` files, but may declare users or home-manager modules elsewhere (for example if it needs a database user).

# When should I make a a new _feature_?

Edit host or user configuration files first.

Resist the urge to have many many small features. A feature should be split when it doesn't make sense to deploy the whole feature on a particular host.

Resist the urge to create new features. A desktop environment is a thing to deploy on multiple desktops/laptops, but not many things are. If I start to see lots of repetition in nix files then maybe yeah, time to make a feature.

# What assumptions am I making when building _features_?

I will be making a few assumptions to simplify my learning curve of nixos. These assumptions may well break over time and I'll need to restructure things. It's fine to not over generalize on day 1.

1. I assume "catalin" is the only human user for the forseeable future.
2. I can write dotfiles directly in a `.dotfiles` folder and users will not need to alter them.
3. It's simpler to write dotfiles exactly as a package expects them (.toml, .ini...) instead of using the nix language. This is because I can copy paste from examples/documentation from other platforms.
4. I should only translate dotfiles to nix files when I need automation (for example paths change between hosts). When dotfiles move to the nix language, a whole file should be moved.
