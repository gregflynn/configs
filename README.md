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
```bash
# ~/.sanity/MODULE/init.sh

function __dotsan__MODULE__init {
    case $1 in
        check)
            case $2 in
                required) echo "linux" ;; # echo required packages
                suggested) echo "bash" ;; # echo suggested packages
            esac
            ;;
        build)
            # prepare configuration files for linking
            ;;
        install)
            # link up configuration files
            ;;
    esac
}
```

### Module Globals
- `__dotsan__link` $module $module_file_path $home_relative_path
    - Link a configuration file from the module directory
- `__dotsan__inject` $module $template [$output]
    - Template a configuration file with the color constants defined in `setup.sh`

## goals
* never check in package code
* make it easy to apply configs
* No additional steps beyond `setup.sh`
* `setup.sh` is rerunable without error
