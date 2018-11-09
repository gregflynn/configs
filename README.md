# dotsanity
this is a, mediocre at best, attempt to keep my configuration files in a manageable place

![Image of dotsanity prompt](dotsanity.png)

## current features
* [Alacritty](https://github.com/jwilm/alacritty) config
* [Ranger](https://github.com/ranger/ranger) configuration with image support in Alacritty
* [rofi](https://github.com/DaveDavenport/rofi) configuration and Awesome-WM integrations
* Pacman wrapper with AUR support
  * `pac [update|install|remove|search] [package_name]`
* bashrc
  * supports private variable sourcing
  * multi file organization
  * python fabric autocomplete
  * git autocomplete
* global git configuration
* vimrc
* Awesome Window Manager
  * Custom configuration
  * Compartmentalized Widget
* Tilix config

## install
```
git clone https://github.com/gregflynn/dotsanity.git ~/.sanity
bash ~/.sanity/setup.sh
```

## Module Boilerplate
`$ dotsan init MODULE_NAME`
This command will create all scaffolding required for creating a new module

### Module Globals
- `__dotsan__inject` $module $template [$output]
    - Template a configuration file with constants defined in `setup.sh`
- `__dotsan__syslink` $module $source $link_location
    - Symlink from anywhere on the system to the dotsanity repo
- `__dotsan__link` $module $source $home_link_location
    - Symlink from anywhere in the user's home directory to the dotsanity repo
- `__dotsan__mirror__syslink` $module $mirror_directory $target_directory $clean
    - Symlink recursively from the target directory to the dotsanity repo
- `__dotsan__mirror__link` $module $mirror_directory $target_directory $clean
    - Symlink recursively from the target directory in the user's home to the dotsanity repo

## goals
* never check in package code
* make it easy to apply configs
* No additional steps beyond `setup.sh`
* `setup.sh` is rerunable without error
