{ config, lib, pkgs, inputs, system, ... }:
# to be modulazrized as overlay, well maybe
let

  unstable = import (fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
      overlays = [
        (import (builtins.fetchTarball {
          url =
            "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
        }))
      ];
    };



#let
#  inherit (pkgs) callPackage;
#  overlays = [
    # If you want to completely override the normal package
    # (prev: final: import ./pkgs { inherit pkgs; })
    # If you want to access your package as `local.emacs`
    # (prev: final: {
    #   local = import ./pkgs { inherit pkgs; };
    # })
    # `prev: final:` is my preference over `super: self:`; these are just
    # names, but I think mine are clearer about what they mean ;)

    # You can also use `my` instead of `local`, of course, but I dislike
    # that naming convention with a passion. At best, it should be
    # `our`.
 # ];
in
{ #instead of emacs-above
  #emacs = callPackage ./emacs.nix { };
    imports =
    [ # Include the results of the hardware scan.

#      inputs.guix-overlay.overlays.default
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";
  #i18n.defaultLocale = “en_us.UTF-8”;
nix.nixPath = [
  #"nixpkgs=/home/pub/clone/nixpkgs"
  #"nixos-config=/etc/nixos/configuration.nix"
  "/nix/var/nix/profiles/per-user/root/channels"
];
nix.settings.trusted-users = [ "root" "pub" ];
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };
  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };
  fonts = {
    #enableDefaultPackages = true;
    fontDir.enable = true;

  };
  #fonts.packages = with pkgs; [
  #jetbrains-mono
 # ];
 nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.openssh.enable = true;
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.pub = {
    isNormalUser = true;
    description = "pub";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      mu
      sqlite
      jami
      pinentry
      gnupg1
    ];
  };
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
  elisa
  gwenview
  print-manager
];

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    #for sway apps
    XDG_RUNTIME_DIR = "/run/user/1000";
    #for systemsctl
    #XDG_RUNTIME_DIR = "/run/user/$(id -u)";
    #experiment
    #WaylandEnable=false;
    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  services.xserver.displayManager.autoLogin.enable = false;
  services.xserver.displayManager.autoLogin.user = "pub";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    #firmware
    fwupd
    #usb
    veracrypt
    cryptsetup
    chromium
    #nyxt
    # pkgs.emacsWithPackagesFromUsePackage rec {
    #   config = let
    #     tangledOrgConfig = pkgs.runCommand "tangled-emacs-config" {} ''
    #       cp ${~/.emacs.d/config.org} init.org
    #       ${package}/bin/emacs --batch -Q init.org -f org-babel-tangle
    #       cp init.el $out
    #     '';
    #   in builtins.readFile tangledOrgConfig;
    #   package = pkgs.emacsGit;
    #   extraEmacsPackages = epkgs: [
    #   epkgs.mu4e
    #   epkgs.emacsql-sqlite
    #   epkgs.vterm
    #   epkgs.pdf-tools
    # ];
    #}
    emacs29-pgtk
    oath-toolkit
    xclip
    xsel
    fish
    #build
    libtool
    cmake
    gnumake
    gcc
    #sakura
    foot
    # don't compile
    cachix
    # verify
    #pinentry
    #gnupg1
    #monkeysphere
    gitAndTools.gitFull
    #gitAndTools.grv
    xorg.xhost
    aspell
    hunspell
    wofi
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
    # nix
    nixpkgs-lint
    nixpkgs-fmt
    nixfmt

    #automatic emacs pm
    # (pkgs.emacsWithPackagesFromUsePackage {
    #   #pkgs.emacs;
    #   config = /home/pub/.emacs.el;
    #   alwaysEnsure = true;
    #   alwaysTangle = true;
    # })
      #tmux
      dunst
      xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib
      ncurses5
      stdenv.cc
      dig
  ];
  services.guix.enable = true;
  services.emacs.enable = true;
  services.emacs.package = pkgs.emacs29-pgtk;

  programs.mtr.enable = true;
  programs.hyprland.enable = true;
  programs.ssh =
    {
      extraConfig = ''
        Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
      '';
    };
    programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      wf-recorder
      mako
      grim
      slurp
      sakura
      dmenu
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
  programs.waybar.enable = true;
  qt.platformTheme = "qt5ct";
  services.pcscd.enable = true;
  # systemd.services.veradecrypt = {
  #   wantedBy = [ "multi-user.target" ];
  #   description = "Decrypt veracrypt data container";
  #   after = ["trousers"];
  #   requires = ["trousers"];
  #   path = [pkgs.bash pkgs.coreutils pkgs.veracrypt pkgs.lvm2 pkgs.util-linux pkgs.ntfs3g pkgs.systemd ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = "yes";
  #     ExecStart = "${pkgs.systemd}/lib/systemd/systemd-cryptsetup attach vera /dev/disk/by-partuuid/<partuuid> /etc/passfile tcrypt-veracrypt,tcrypt-keyfile=";
  #     ExecStop = "${pkgs.systemd}/lib/systemd/systemd-cryptsetup detach vera";
  #   };
  # };

  # systemd.mounts = [{
  #   enable = true;
  #   wantedBy = [ "multi-user.target" ];
  #   description = "Mount veracrypt data container";
  #   after = ["veradecrypt.service"];
  #   requires = ["veradecrypt.service"];
  #   where = "/run/mount/data";
  #   type = "ntfs-3g";
  #   what = "/dev/mapper/vera";
  #   options = "rw,uid=1000,gid=100,umask=0077";
  # }

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
