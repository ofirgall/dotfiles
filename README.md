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
git clone https://github.com/ofir753/dotfiles.git && cd dotfiles && sudo echo a && ./install --config-file remote.conf.yaml
```

### Clone and Run for PC
```bash
git clone https://github.com/ofir753/dotfiles.git && cd dotfiles && sudo echo a && ./install
```

Incase you are using windows terminal add `windows_terminal_binds.json` to your windows terminal

---

## TODO:
