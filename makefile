all:
	stow --verbose --target=$$HOME --restow */

basics:
	stow --verbose --target=$$HOME --restow vim
	stow --verbose --target=$$HOME --restow git
	stow --verbose --target=$$HOME --restow zathura
	stow --verbose --target=$$HOME --restow bash
	stow --verbose --target=$$HOME --restow bins
delete:
	stow --verbose --target=$$HOME --delete */
