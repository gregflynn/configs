# dotsanity
this is a, mediocre at best, attempt to keep my configuration files in a manageable place

![Image of dotsanity prompt](dotsanity.png)

## current features
* [Alacritty](https://github.com/jwilm/alacritty) config
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

## Requirements
- bash
- Python 3.4+

## install
```
git clone https://github.com/gregflynn/dotsanity.git ~/.sanity
bash ~/.sanity/setup.sh
```
