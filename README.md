#name is a bit misleading, I am not associated to derminate sytems, it's usable for the times when your root folder paths adn channels are not very detministic.
## root flake for flake without channels, paths
1. backup your /etc/nixos
2. git clone this repo to that dir
3. cd dir && git {add, commit -m  ..} 
4. nix flake { update,lock} [ this is same as path as channel and run the rebuild [^1] , so you can delete any channel, which is lockng your "/run/user/1000/nix-build-boot.json.drv-0" 
5. run it again
6. open your old and new configs in $EDITOR  and check the diff, not the diff and so long as you get it ( it fairly straightforward, at least the flakes}, you can mod it towards yours or mine or something else
7. last and very point of writing , sharing this
	1. this flake can't be derived from the "nix repl" tool , so long as you get , what you eval. I ll share my repl.nix with as many detail , as can be close to general purpose, shortly.
### notes
1. many and soon most configs ll be stored in /nix/store .
   1. they are immutable and you can't mod them in dotfiles, because you found something to try
   2. to use that new , build it with nix and then configs ll have it.
   3. that way I can save the current state of my configs and serve /nix/store on a NAS, for my other machines. so even if one crashes or I delete everything else upon a reboot ,all states of my work are pre preserved.I may opt to serve it on a cloud.

2. this config uses gtk desktop portal for wlr,xdg etc, its deprecated on nixos.
[^1]: rebuild
```
nixos-rebuild -I  nixpkgs=https://nix
xos-config=./ switch
```

