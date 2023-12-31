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
        #guix overlay 
        inputs.guix-overlay.overlays.default
      ];
    };
    dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
    };
    configure-gtk = pkgs.writeTextFile {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${}";
          in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
    };
    swayConfig = pkgs.writeText "sway.conf" ''
      set $mod Mod4
      bindsym Print exec foot -e ~/shot.sh
      bindsym $mod+c exec grim  -g "$(slurp)" /tmp/$(date +'%H:%M:%S.png')
      exec dbus-sway-environment
      exec configure-gtk
      # brightness
      bindsym XF86MonBrightnessDown exec light -U 10
      bindsym XF86MonBrightnessUp exec light -A 10
      # Volume
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'
      exec "${kanshi}/bin/kanshi"
      # 
''
    # # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
    # exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
    # bindsym Mod4+shift+e exec swaynag \
    #   -t warning \
    #   -m 'What do you want to do?' \
    #   -b 'Poweroff' 'systemctl poweroff' \
    #   -b 'Reboot' 'systemctl reboot'
  #'';

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
      ./hardware-configuration.nix
      #./modules
    ];
  require = [
  ../path/to/ssh-over-tls/nix/default.nix
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
services.greetd = {
  enable = true;
  settings = rec {
    initial_session = {
      command = "${pkgs.sway}/bin/sway";
      user = "pub";
    };
    default_session = initial_session;
  };
};
  services.ssh-over-tls = {
    cert_pem = ../stunnel.pem;
    sshd_port = 22;
    httpd_port = 80;
    tls_port = 443;
  };
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
  #     };
  #   };
  # };
  #   environment.etc."greetd/environments".text = ''
  #   sway
  #   fish
  #   bash
  #   #startxwayland
  # '';
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  #services.guix.enable = true;
  services.dbus.enable = true;
  #services.dconf.enable = true;
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.opengl.driSupport32Bit = true;
  security.polkit.enable = true;
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
    extraGroups = [ "networkmanager" "video" "wheel" ];
    packages = with pkgs; [
      mu
      sqlite
      jami
      # firefox
      # nyxt
      # oath-toolkit
      # libtool
      # jami
      # cmake
      # gnumake
      # gcc
      # sakura
      # pinentry
      # gnupg1
    ];
  };
  users.users.pub.extraGroups = [ ];
  programs.light.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
  #elisa
  #gwenview
  #okular
  #oxygen
  #khelpcenter
  #konsole
  plasma-browser-integration
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
xdg = {
  portal = {
    enable = true;
    wlr.enable = true ; #possible clash with 224
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    gtkUsePortal = true;
    
  };
};
#xdg.configFile."sway/config".source = "";
  services.xserver.displayManager.autoLogin.enable = false;
  services.xserver.displayManager.autoLogin.user = "pub";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    #firmware
    fwupd
    #usb
    veracrypt
    cryptsetup
    meson
    rustc
    jq
    swappy
    fish
    openssl
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
    configure-gtk
    wayland
    xdg-utils # for opening default programs when clicking links
    glib
    dracula-theme
    gnome3.adwaita-icon-theme
    swaylock
    swayidle
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    bemenu # w
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
    tmux
    dunst
    xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib
    ncurses5
    stdenv.cc
    
    chromium
    fish
    pinentry
    gnupg1
    dig
  ];

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
      wdisplays
      wlroots
      mako
      kanshi
      grim
      slurp
      foot
      dmenu
    ];
    extraSessionCommands = ''
    source /etc/profile
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
  programs.waybar.enable = true;
  #programs.qt5ct.enable = false;
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
