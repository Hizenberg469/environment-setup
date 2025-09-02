#!/bin/bash

: << cmt

This script is used to setup the environment
for development in C and C++.

cmt


user=""
if [ "$(whoami)" = "root" ]; then
    user=""
else
    user="sudo"
fi


# To setup the environment

function settingUpVimrc {
    
    # Installing the required packages for plugin.
    $user apt install universal-ctags -y
    $user apt install -y global
    $user apt install -y clang-tidy
    $user apt install -y clang-format

    # Setting up the .vimrc
    VIMRC_LOCATION=$($user find $HOME/ .vimrc)
    if [ "$HOME/.vimrc" = "$VIMRC_LOCATION" ]; then
        $user mv $HOME/.vimrc $HOME/.vimrc.bck
    fi

    cp $(pwd)/.vimrc $HOME/.vimrc
}


# To remove vimrc.

function removeVimrc {
    $user apt purge universal-ctags -y
    $user apt install -y global

    VIMRC_LOCATION=$($user find $HOME/ -type f -name .vimrc.bck)
    if [ "$HOME/.vimrc.bck" = "$VIMRC_LOCATION" ]; then
        $user rm $HOME/.vimrc
        $user mv $HOME/.vimrc.bck $HOME/.vimrc
    fi
}


# To setup latest vim

function settingUpLatestVim {
    
    # Installing the required packages.
    $user apt install -y libncurses-dev libatk1.0-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev \
libpython3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git
    
    # Configure for compilation.
    local DIR='/usr/local' # Directory to setup the latest vim build.
    if [ $# -gt 0 ]; then
        DIR=$1
    fi
    
    if [ '$DIR' = '/usr/local' ]; then
        $user apt remove -y vim vim-runtime gvim
        $user apt remove -y vim-tiny vim-comman vim-gui-comman vim-nox
    else
        mkdir $DIR
        mkdir -p $DIR/share/vim/vim91
        echo -e "\n\n\nalias vim=$DIR/bin/vim" >> ~/.bashrc
        echo -e "\nexport VIMRUNTIME=$DIR/share/vim/vim91" >> ~/bashrc
        echo -e "\nexport PATH=$DIR/bin:\$PATH" >> ~/.bashrc
        source ~/.bashrc
    fi
    
    cd ~
    git clone https://github.com/vim/vim.git
    cd ~/vim
    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp=yes \
                --enable-python3interp=yes \
                --with-python3-config-dir=$(python3-config --configdir) \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --enable-gui=no \
                --enable-cscope \
                --prefix=$DIR
   
    # Issue in wayland header file. Hence, running this.
    cd ~/vim/src/auto/wayland/
    make

    cd ~/vim/src
    make VIMRUNTIMEDIR=$DIR/share/vim/vim91

    # To track the source build as a package for easy uninstallation.
    $user apt install checkinstall
    cd ~/vim/src
    
    if [ '/usr/local' = $DIR ]; then
        $user checkinstall --fstrans=no # To avoid temporary filesystem translation issue.
    else
        make install
    fi
    
    #Symbolic just in case.
    $user ln -s $DIR/share/vim/vim91 /usr/share/vim

    # Install plugin for vim-plug.
    vim +PlugInstall +qall
}


# To remove vim 
function removeVim {
    
    # Uninstall Vim
    $user apt purge -y vim

    $user apt purge -y libncurses-dev libatk1.0-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev \
libpython3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git
        
    local DIR='/usr/local' # Directory to setup the latest vim build.
    if [ $# -gt 0 ]; then
        DIR=$1
    fi
    
    if [ $DIR = '/usr/local' ]; then
        $user apt install -y vim vim-runtime gvim
        $user apt install -y vim-tiny vim-comman vim-gui-comman vim-nox
    fi

    rm -rf ~/.vim/

    $user rm -rf /usr/share/vim
}




# To setup YouCompleteMe (YCM)

function settingUpYCM {
    cd ~/
    
    # Installing Vundle and installing the plugin. Also, for vim-plug manager.
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall

    # Install CMake and Python
    $user apt install -y build-essential cmake python3-dev

    # Compile YCM
    cd ~/.vim/bundle/YouCompleteMe
    python3 install.py --clangd-completer
}



# Removing the YCM

function removeYCM {
    
    echo "Nothing to do"
    # Remove mono-complete, go, node, java and npm
    # $user apt purge -y mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm
}


################ Starting the execution here ###################
# If directory is mentioned.
opts=$(getopt -o a --long help,dir::,mode: -- "$@")
eval set -- "$opts"

VIM_DIR=""
MODE=""
while [ $# -gt 1 ]
do
    case "$1" in
        --dir) VIM_DIR=$2
               shift 2
               ;;
               
        --mode) MODE=$2
                shift 2
                ;;

        --help)  echo -e "$0 --dir=<directory for vim installation> --mode install|uninstall\n" \
                 "--dir  : Optional [E.g: --dir=$HOME/Vim ]\n" \
                 "--mode : install ( setting up the environment )\n" \
                 "         uninstall ( returning to default )\n"
                 shift
                 exit 0
                 ;;

        *) echo "$2 : Unknown parameter or no parameter"
           echo "Please provide correct parameter"
           echo "USAGE: ./env_setup.sh --help"
           exit 1 
           ;;
    esac
done


if [ "install" = "$MODE" ]; then
    settingUpVimrc
    
    if [ "" = "$VIM_DIR" ]; then
        settingUpLatestVim
    else
        settingUpLatestVim $VIM_DIR
    fi
    
    settingUpYCM
elif [ "uninstall" = "$MODE" ]; then
    removeVimrc

    if [ "" = "$VIM_DIR" ]; then
        removeVim 
    else
        removeVim $VIM_DIR
    fi

    removeYCM
    $user apt clean
else
    echo "Wrong argument to --mode option"\
        "Use env_set.sh --help"
    exit 1
fi
