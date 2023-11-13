all:
	stow --verbose --target=$$HOME --restow */
delete:
	stow --verbose --target=$$HOME --delete */
base:
	stow --verbose --target=$$HOME --restow vim bash x
