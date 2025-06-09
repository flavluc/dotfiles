{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;  # Using the default Emacs package
    extraPackages = (
      epkgs: with epkgs; [
	deadgrep
	org
	org-bullets
	treemacs
        all-the-icons        # Icons package for Emacs
        cider                # Clojure REPL support
        clojure-mode         # Clojure support
        company              # Autocompletion
        counsel              # Navigation & search
        counsel-projectile   # Project management Counsel integration
        doom-modeline        # Modern modeline
        flycheck             # Syntax checking
        helpful              # Commands descriptions
        ivy-rich             # Adds extra details to Ivy menus
        magit                # Git integration
        modus-themes         # Themes
        paredit              # Lisp structural editing
        projectile           # Project management
        rainbow-delimiters   # Parentheses highlighting
        use-package          # Package manager
        which-key            # Keybinding helper
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
