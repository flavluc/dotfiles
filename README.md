dotfiles
==========

configuration files for my operating system (still a work in progress). these are pretty specific to my needs and taste, but you may find something useful.

 ## screenshots
 
![terminal](screenshots/terminals.png)

![editor](screenshots/editor.png)

![browser](screenshots/browser.png)

![background](screenshots/background.png)

## todos

 - build system
 - install home manager
 - build home
 - install nixGL
 ```
 $ nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl && nix-channel --update
 $ nix-env -iA nixgl.auto.nixGLDefault   # or replace `nixGLDefault` with your desired wrapper
 ```
 - install treestyle-tabs
