# Ofir's DotFiles

## Install
### Enable pre-commit hook for saving stuff (like dconf)
```bash
ln -s ../../pre-commit .git/hooks/pre-commit
```

### Set Git User
Set your `global` git user at ~/.git_user
```
[user]
	name = "Your Name"
	email = "yourname@gmail.com"
```

### Set Local Repo (for me)
Set `this repo` git user
```
git config user.email "ofirgal753@gmail.com"
git config user.user "Ofir Gal"
```

### Clone and Run for Remote
```bash
git clone https://github.com/ofir753/dotfiles.git && cd dotfiles && sudo echo a && ./install --config-file remote.conf.yaml && touch ~/.remote_indicator
```

### Clone and Run for PC
```bash
git clone https://github.com/ofir753/dotfiles.git && cd dotfiles && sudo echo a && ./install
```

Incase you are using windows terminal add `windows_terminal_binds.json` to your windows terminal

---

## TODO:
* tmux - make a valid fix for suspend/resume copy like copycat mode

---

## How to set VIM binds with Capslock modifer
### Sources
* https://wiki.archlinux.org/title/X_keyboard_extension#Caps_hjkl_as_vimlike_arrow_keys
* https://ts-cubed.github.io/roam/20210525184028-keyboard_mapping.html#orgc60c5b3

`/usr/share/X11/xkb/types/complete`
```
default xkb_types "complete" {
	...
	type "CUST_CAPSLOCK" {
       modifiers= Shift+Lock; 
       map[Shift] = Level2;            //maps shift and no Lock. Shift+Alt goes here, too, because Alt isn't in modifiers.
       map[Lock] = Level3;
       map[Shift+Lock] = Level3;       //maps shift and Lock. Shift+Lock+Alt goes here, too.
       level_name[Level1]= "Base";
       level_name[Level2]= "Shift";
       level_name[Level3]= "Lock";
   };
};
```
`/usr/share/X11/xkb/types/complete`
```
default xkb_compatibility "complete" {
	...
    interpret Caps_Lock+AnyOfOrNone(all) {
       action= SetMods(modifiers=Lock);
   };
};
```
`/usr/share/X11/xkb/symbols/us`
```
key <AE04> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               4,               dollar,        End ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<END>, clearmods=Lock) ]
    };
key <AE10> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               0,               parenright,        Home ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<HOME>, clearmods=Lock) ]
    };
key <AD07> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               u,               U,        Prior ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<PGUP>, clearmods=Lock) ]
    };
key <AC03> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               d,               D,        Next ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<PGDN>, clearmods=Lock) ]
    };
key <AC06> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               h,               H,        Left ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<LEFT>, clearmods=Lock) ]
    };
key <AC07> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               j,               J,       Down ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<DOWN>, clearmods=Lock) ]
    };
key <AC08> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               k,               K,       Up ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<UP>, clearmods=Lock) ]
    };
key <AC09> {
        type= "CUST_CAPSLOCK",
        symbols[Group1]= [               l,               L,       Right ],
        actions[Group1]= [      NoAction(),     NoAction(),    RedirectKey(Keycode=<RGHT>, clearmods=Lock) ]
    };
```
