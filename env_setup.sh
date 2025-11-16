#!/bin/bash -
#
#DEFINE THE ENVIRONMENT VARIABLE:
#
#ORIGINAL_DIR: Directory where this script is present
#               along with other required utility
#               to setup the Dev environment.
#REPO_HOSTING_PLATFORM ( Eg. github, gitlab, etc )
#CODEQUERY_GUI
#   YES - To install codequery with GUI.
#   NO  - To install codequery without GUI.
#
# Peform the below command before executing this script.
#   source $PWD/env_variable

RETURN_SUCCESS=0
RETURN_FAILURE=255
my_vimrc='$ORIGINAL_DIR/my_vimrc'
essential_plugins=( 
    WolfgangMehner/bash-support,
    WolfgangMehner/c-support,
    WolfgangMehner/perl-support,
    preservim/nerdtree,
    luochen1990/rainbow,
    preservim/tagbar,
    mbbill/undotree,
    vim-airline/vim-airline,
    vim-airline/vim-airline-themes,
    bfrg/vim-c-cpp-modern,
    kovetskiy/vim-bash,
    tomasiser/vim-code-dark,
    ArthurSonzogni/Diagon,
    tpope/vim-commentary,
    tpope/vim-fugitive
)   

optional_plugins=(
    dense-analysis/ale,
    ycm-core/YouCompleteMe
)

# checkStatus 1 -- To exit the script
# checkStatus 0 -- To return 255(failure) value
# checkStatus <status> {(optional)status-message}
function checkStatus {
  
    to_exit=$1
    cmd_status=$?

    last_cmd=$(history | tail -3 | head -1 | sed 's/^[ ]*[0-9]\+[ ]*//')
    if [ $cmd_status -ne 0 ] ; then
       echo "Last command: $last_cmd has failed"
       
       if [ $# -gt 1 ] ; then 
           echo -e "$2"
       fi

       if [ $to_exit -eq 1 ] ; then
           exit $RETURN_FAILURE
       else 
           return $RETURN_FAILURE
       fi
    fi

    return $RETURN_SUCCESS
}

# printStatus <message> <status> {(optional}expected-status>
function printStatus {

    if [ $# -lt 2 || $# -gt 3 ] ; then
        echo -e "Status message and status return value is not passed.\nNeed to fail due to incorrect script."
        exit $RETURN_FAILURE
    fi

    message=$1
    status=$2
    
    expected_status_number=0
    if [ $# -gt 2 ] ; then
       expected_status_number=$2
    fi

    if [ $status -ne $expected_status_number ] ; then
        echo -e "$message"
    fi
}

# findFileOrDir <file or dir name> {(opt)dir} {(opt)type[t|d]} {(opt)maxdepth}
# return "" if not found
# return path to where it is present if found
function findFileOrDir {
    
    if [ $# -lt 1 ] ; then
        echo -e "Atleast provide the file name to search for.
Exiting the script as the function \"findFileOrDir\" not
properly used."
        exit $RETURN_FAILURE
    fi

    name=$1
    seach_dir="."
    type="f"
 
    if [ $# -gt 1 ] ; then
        search_dir=$2
    fi
    
    if [ $# -gt 2 ] ; then
        type=$3
    fi

    is_present=""
    if [ $# -gt 3 ] ; then
        mx_depth=$3
        is_present=$(find $search_dir -maxdepth $mx_depth -type $type -name $name | head -1)
    else
        is_present=$(find $search_dir -type $type -name $name | head -1)
    fi

    checkStatus 0
    return $is_present
}

# checkPkgIsInstalled <pkg-name> {(opt)number -- whether to install the package}
# number - 1 to install or 0 to not install. Defualt = 0
# return 255 -- Not installed
# return 0 -- Installed
function checkPkgIsInstalled {

    if [ $# -lt 1 ] ; then
        echo "Atleast pass the package-name.\nExiting the script due to incorrect usage of /'checkPkgIsInstalled/' function"
        exit $RETURN_FAILURE
    fi
    pkg_name=$1
    
    to_install=0
    if [ $# -gt 1 ] ; then
        to_install=$2
    fi

    is_installed=$(dpkg-query -W -f='${binary:Package}\n' | grep -wo 'qmake' | head -1)
    if [ '$is_installed' = '$pkg_name' ] ; then
        echo "$pkg_name is already installed"
        return $RETURN_SUCCESS # Installed
    else
        if [ $to_install -eq 1 ] ; then
            echo "Installing the package: $pkg_name"
            sudo apt install $pkg_name -y
            checkStatus 0 "Unsuccessful in installing $pkg_name"
            status=$?
            if [ $status -eq 0 ] ; then
                echo "$pkg_name is installed"
                return $RETURN_SUCCESS # Installation success
            fi
        fi
    fi

    return $RETURN_FAILURE # Not Installed
}

#checkReposIsCloned <repo> <path> {(opt)to be cloned or not} {(opt)to clone recursively} {(opt)
#hosting platform}
#{ to be cloned or not} : 1 for clonning , 0 for not clonning
#{ to clone recursively} : 1 for YES, 0 for no
function checkRepoIsCloned {
   
    if [ $# -lt 2 ] ; then
        echo "Atleast mention the Repo and the path to where it is cloned"
        echo "Exiting the script due to incorrect usage of function /'checkRepoIsCloned/'"
        exit $RETURN_FAILURE
    fi

    repo=$1
    path=$2
    to_cloned=0
    if [ $# -gt 2 ] ; then
        to_cloned=1
    fi

    is_recursive=0
    if [ $# -gt 2 ] ; then
       is_recursive=$3 
    fi

    repo_hosting_platform=$REPO_HOSTING_PLATFORM
    if [ $# -gt 3 ] ; then
        repo_hosting_platform=$4
    fi

    findFileOrDir "$1" "$2" "d" "1"
    is_dir_present=$?
    if [ "$is_dir_present" != "$2/$1" ] ; then
        if [ $to_cloned -eq 1 ] ; then
            if [ $is_recursize -eq 1 ] ; then
                git clone --recurse-submodules "$repo_hosting_platform/$repo.git" "$path" 
            else
                git clone "$repo_hosting_platorm/$repo.git" "$path"
            fi
            
            checkStatus 0 "Unsuccessful in cloning the repo: $repo"
            status=$?
            if [ $status -eq 0 ] ; then
                echo "Successfully cloned the repo: $repo"
                return $RETURN_SUCCESS #Clonned successfully
            fi
        else
            echo "Repo : $repo is not present."
        fi
    else
        echo "Repo: $repo is already present"
        return $RETURN_SUCCESS # Repo present
    fi

    return $RETURN_FAILURE # Repo not present
}

function setUpVimrc {
    check_vimrc_location=$(find $HOME -maxdepth 1 -type f -name ".vimrc" | head -1)
    checkStatus 1

    if [ "$check_vimrc_location" = "$HOME/.vimrc" ] ; then
        if [ "$(tail -1 $HOME/.vimrc)" != "\" My vimrc end -- Hizenberg" ] ; then
            mv $HOME/.vimrc $HOME/.vimrc.bck
            checkStatus 1
            cp $my_vimrc $HOME/
            checkStatus 1
            mv $HOME/.my_vimrc $HOME/.vimrc
            checkStatus 1
        else
            echo "My vimrc is already present"
            return $RETURN_SUCCESS
        fi
    else
        cp $my_vimrc $HOME/
        checkStatus 1
        mv $HOME/.my_vimrc $HOME/.vimrc
        checkStatus 1
    fi

    echo "My vimrc setup is done!!!"
    return $RETURN_SUCCESS
}

function getVimVersion {
    version=$(vim --version | head -n 1 | awk '{print $5}')
    checkStatus 1
    version=$(echo "$ver_num" | bc -l)
    checkStatus 1

    return version
}

function setUpPluginDir {
    is_dir_present=$(find $HOME -maxdepth 1 -type d -name ".vim")
    checkStatus 1

    if [ "$is_dir_present" != "$HOME/.vim" ] ; then
        mkdir -p $HOME/.vim/pack/default/start
        mkdir -p $HOME/.vim/pack/default/opt
        checkStatus 1 "Couldn't create plugin directory"

        echo ".vim directory is created for plugins"
    else
        echo ".vim directoyr is already present for plugins"
    fi
    return $RETURN_SUCCESS
}



function setUpYCM {
   
    checkRepoIsCloned "${optional_plugins[ ${#optional_plugins[@]} - 1 ] }.git" "$HOME/.vim/pack/default/opt/" 1 1

    checkPkgIsInstalled "build-essential" 1
    checkPkgIsInstalled "cmake3" 1
    checkPkgIsInstalled "python3-dev" 1
    
    cd ~/.vim/pack/default/opt/YouCompleteMe

    python3 install.py --clangd-completer
    checkStatus 0 "Failure!!! YCM is not configured for C/C++ projects"
    status=$?

    return $status
}


function setUpCodeQuery {
    req_packages=(
        build-essential,
        g++,
        git,
        cmake,
        ninja-build,
        sqlite3,
        libsqlite3-dev,
        cscope,
        pycscope,
        starscope,
        universal-ctags
    )

    gui_packages=(
        libglx-dev,
        libgl1-mesa-dev,
        libvulkan-dev,
        libxkbcommon-dev,
        qt6-base-dev,
        qt6-base-dev-tools,
        qt6-tools-dev,
        qt6-tools-dev-tools,
        libqt6core5compact6-dev,
        qt6-l10n-tools,
        qt6-wayland
    )

    for (( i=0 ; i < ${#req_packages[@]} ; i++ ))
    do
        checkPkgIsInstalled "$req_packages[ $i ]" 1
        status=$?
        
        if [ $status -ne 0 ] ; then
            return $RETURN_FAILURE
        fi
    done

    checkRepoIsCloned "ruben2020/codequery" "$ORIGINAL_DIR" 1
    status=$?
    if [ $status -ne 0 ] ; then
        return $RETURN_FAILURE
    fi

    findFileOrDir "codequery" "$HOME/tools" "d" "2" 
    is_dir_present=$?
    if [ "$is_dir_present" != "$HOME/tools/codequery" ] ; then
        mkdir -p $HOME/tools/codequery
    fi

    cd $ORIGINAL_DIR/codequery

    if [ "$CODEQUERY_GUI" = "YES" ] ; then
        for (( i=0 ; i < ${#gui_packages[@]} ; i++ ))
        do
            checkPkgIsInstalled "$gui_packages[ $i ]" 1
            status=$?

            if [ $status -ne 0 ] ; then
                return $RETURN_FAILURE
            fi
        done
        cmake -DCMAKE_INSTALL_PREFIX="$HOME/tools/codequery" -G Ninja -S . -B build
    else
        cmake -DCMAKE_INSTALL_PREFIX="$HOME/tools/codequery" -G Ninja -DNO_GUI=ON -S . -B build
    fi

    cmake --build build
    sudo cmake --install build
}


function setUpVimCodeQuery {
    
    checkRepoIsCloned "Shougo/unite.vim" "$HOME/.vim/pack/default/opt/" 1
    status=$?
    if [ $status -ne 0 ] ; then
        return $RETURN_FAILURE
    fi

    checkReposIsCloned "devjoe/vim-codequery" "$HOME/.vim/pack/default/opt/" 1
    status=$?
    if [ $status -ne 0 ] ; then
        return $RETURN_FAILURE
    fi

    return $RETURN_SUCCESS
}

BANNER=$(<banner.txt)
echo "$BANNER" 



