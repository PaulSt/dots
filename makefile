default_target: all
all:
	stow --verbose --target=$$HOME --restow vim
	stow --verbose --target=$$HOME --restow git
	stow --verbose --target=$$HOME --restow zathura
	stow --verbose --target=$$HOME --restow bash
	stow --verbose --target=$$HOME --restow bins
	stow --verbose --target=$$HOME --restow suckless
	stow --verbose --target=$$HOME --restow wm
	stow --verbose --target=$$HOME --restow jgmenu
delete:
	stow --verbose --target=$$HOME --delete */
base:
	stow --verbose --target=$$HOME --restow vim bash x
everything:
	stow --verbose --target=$$HOME --restow */
