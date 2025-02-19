{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;  # Using the default Emacs package
    extraPackages = (
      epkgs: with epkgs; [
        use-package          # Package manager
        which-key            # Keybinding helper
        all-the-icons        # Icons package for Emacs
        doom-modeline        # Modern modeline
        modus-themes         # Themes
        rainbow-delimiters   # Parentheses highlighting
        counsel              # Navigation & search
        ivy-rich             # Adds extra details to Ivy menus
        helpful              # Commands descriptions
        projectile           # Project management
        counsel-projectile   # Project management Counsel integration
        magit                # Git integration
        company              # Autocompletion
        flycheck             # Syntax checking
        clojure-mode         # Clojure support
        paredit              # Lisp structural editing
        cider                # Clojure REPL support
	org
	org-bullets
	visual-fill-column
      ]
    );
  };

  home.file = {
    ".emacs.d" = {
      source = ./emacs.d;
      recursive = true;
    };
  };

  xresources.properties = {
    "Emacs.menuBar" = false;
    "Emacs.toolBar" = false;
    "Emacs.verticalScrollBars" = false;
  };

  services.emacs.enable = true; # Enable Emacs as a systemd service (optional)
}
