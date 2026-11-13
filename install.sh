#!/bin/bash
##########################
# This install script:
# * makes sure that alacritty, zsh, tmux and neovim are installed correctly
# * creates symlinks from the home directory to the dotfiles in ~/dotfiles
##########################

##########################
# Install dependencies
##########################

if [ -z $(which brew) ]; then
	echo "brew not found. Installing brew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/kqvl629/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ ! -d "/Applications/Alacritty.app" ]; then
	echo "alacritty not found. Installing alacritty..."
	brew install --cask alacritty
fi

if [ -z $(which zsh) ]; then
	echo "zsh not found. Installing zsh..."
	brew install zsh
	echo "Making zsh default shell"
	chsh -s $(which zsh)
fi

if [ -z $(which nvim) ]; then
	echo "neovim not found. Installing neovim..."
	brew install neovim
	echo "Installing python3 and python-for-neovim"
	brew install python3
	pip2 install neovim --upgrade
	pip3 install neovim --upgrade
	pip3 install black --upgrade # Python fixer
	echo "Installing neovim plugins"
	vim +'PlugInstall --sync' +qa
fi

if [ -z $(which tmux) ]; then
	echo "tmux not found. Installing tmux..."
	brew install tmux
fi

if [ -z $(which fzf) ]; then
	echo "fzf not found. Installing fzf..."
	brew install fzf
fi

if [ -z $(which ag) ]; then
	echo "ag not found. Installing ag..."
	brew install the_silver_searcher
fi

##########################
# Install nvm + node + LSP servers
##########################

export NVM_DIR="$HOME/.nvm"
echo "Installing/upgrading nvm to latest..."
NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

if [ -z $(which node) ]; then
	echo "node not found. Installing latest LTS via nvm..."
	nvm install --lts
	nvm use --lts
fi

if [ -z $(which npm) ]; then
	echo "npm not found after nvm/node install — something went wrong."
else
	# typescript@6: ts_ls (typescript-language-server) requires typescript < 7
	npm_packages=(
		"typescript@6"
		"typescript-language-server"
		"@tailwindcss/language-server"
		"bash-language-server"
		"cssmodules-language-server"
		"pyright"
		"vscode-langservers-extracted"
	)
	for pkg in "${npm_packages[@]}"; do
		pkg_name="${pkg%%@[0-9]*}"
		if [ -z "$(npm list -g --depth=0 2>/dev/null | grep "${pkg_name##*/}")" ]; then
			echo "Installing $pkg..."
			npm install -g "$pkg"
		fi
	done
fi

if [ -z $(which opencode) ]; then
	echo "opencode not found. Installing opencode..."
	curl -fsSL https://opencode.ai/v2/install | bash
fi


##########################
# Create symlinks for dotfiles
##########################

dir=$(pwd)
backup_dir=~/dotfiles_backup

# Relative paths for the config files to be installed
dotfile_paths=( \
	alacritty/alacritty.toml \
	zsh/zshrc \
	vim \
	tmux/tmux.conf \
	tmux/tmux.reset.conf \
	opencode/opencode.json \
)
# The target locations at which configs are to be installed
install_paths=( \
	~/.config/alacritty/alacritty.toml \
	~/.zshrc \
	~/.config/nvim \
	~/.tmux.conf \
	~/.tmux.reset.conf \
	~/.config/opencode/opencode.json \
)

# Create dotfiles_old in homedir
if [ ! -d "$backup_dir" ]; then
	echo -n "Creating $backup_dir for backup of any existing dotfiles in home directory... "
	mkdir -p $backup_dir
	echo "Done"
fi

# Link dotfile to its target install path
# Existing dotfiles are moved to the backup directory
install_config () {
	local dotfile_path=$1
	local install_path=$2
	dotfile=$(basename $dotfile_path)
	install_dir=$(dirname $install_path)
	if [ -e "$install_path" ]; then
		echo "Moving existing dotfile $dotfile to $backup_dir."
		mv $install_path $backup_dir
	fi
	echo "Creating symlink to $dotfile at $install_path"
	mkdir -p "$install_dir"
	ln -sfn "$dir/$dotfile_path" "$install_path"
}

for (( i = 0; i < ${#dotfile_paths[@]}; i++))
do
	install_config ${dotfile_paths[i]} ${install_paths[i]}
done

# Prevent local environment-specific settings to be tracked by git
git update-index --skip-worktree zsh/env.zsh
