#!/bin/bash -
#
#DEFINE THE ENVIRONMENT VARIABLE:
#
#ORIGINAL_DIR: Directory where this script is present
#               along with other required utility
#               to setup the Dev environment.
#
#REPO_HOSTING_PLATFORM ( Eg. github, gitlab, etc )
#
#CODEQUERY_GUI
#   YES - To install codequery with GUI.
#   NO  - To install codequery without GUI.
#
#INSTALL_YCM
#   YES - To setup the YCM
#   NO  - To not setup the YCM
#
#INSTALL_CODEQUERY
#   YES - To setup the codequery
#   NO  - To not setup the codequery
#
#INSTALL_VIM_CODEQUERY
#   YES - To setup the vim-codequery
#   NO  - To not setup the vim-codequery
#   
# Peform the below command before executing this script.
#   source $PWD/env_variable

RETURN_SUCCESS=0
RETURN_FAILURE=255
PASSWORD=""
my_vimrc='$ORIGINAL_DIR/my_vimrc'
essential_plugins=( 
    "WolfgangMehner/bash-support"
    "WolfgangMehner/c-support"
    "WolfgangMehner/perl-support"
    "preservim/nerdtree"
    "luochen1990/rainbow"
    "preservim/tagbar"
    "mbbill/undotree"
    "vim-airline/vim-airline"
    "vim-airline/vim-airline-themes"
    "bfrg/vim-c-cpp-modern"
    "kovetskiy/vim-bash"
    "tomasiser/vim-code-dark"
    "wiwiiwiii/vim-diagon"
    "tpope/vim-commentary"
    "tpope/vim-fugitive"
)   

optional_plugins=(
    "dense-analysis/ale"
    "vim-scripts/OmniCppComplete"
    "ludovicchabant/vim-gutentags"
    "skywind3000/gutentags_plus"
)

essential_pkg=(
    "build-essential"
    "gdb"
    "cscope"
    "universal-ctags"
    "global"
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
    
    expected_status_number=$RETURN_SUCCESS
    if [ $# -gt 2 ] ; then
       expected_status_number=$2
    fi

    if [ $status -ne $expected_status_number ] ; then
        echo -e "$message"
    fi
}


# findFileOrDir <file or dir name> {(opt)dir} {(opt)type[f|d]} 
# return 255 if not found
# return 0 if found
function findFileOrDir {
    
    if [ $# -lt 1 ] ; then
        echo -e "Atleast provide the file name to search for.
Exiting the script as the function \"findFileOrDir\" not
properly used."
        exit $RETURN_FAILURE
    fi

    name=$1
    search_dir="."
    type="f"
 
    if [ $# -gt 1 ] ; then
        search_dir=$2
    fi
    
    if [ $# -gt 2 ] ; then
        type=$3
    fi

    is_present=$(find "$search_dir" -type "$type" -name "$name" | head -1)
    checkStatus 0
    
    if [ "$is_present" = "$search_dir/$name" ] ; then
        return $RETURN_SUCCESS
    fi
    return $RETURN_FAILURE
}

# printStatus <message> <status> {(optional}expected-status>
function logStatus {
    
    if [ $# -lt 2 ]  || [ $# -gt 3 ] ; then
        echo -e "Status message and status return value is not passed.\nNeed to fail due to incorrect script."
        exit $RETURN_FAILURE
    fi

    message=$1
    status=$2
    
    expected_status_number=$RETURN_SUCCESS
    if [ $# -gt 2 ] ; then
       expected_status_number=$3
    fi
    
    findFileOrDir "status.txt" "$ORIGINAL_DIR" "f" 
    find_status=$?
    if [ "$find_status" -ne $RETURN_SUCCESS ] ; then
        touch "$ORIGINAL_DIR/status.txt"
    fi
    
    if [ $status -ne $expected_status_number ] ; then
        echo -e "$message : Failure" >> $ORIGINAL_DIR/status.txt
    else
        echo -e "$message : Done" >> $ORIGINAL_DIR/status.txt
    fi
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

    is_installed=$(dpkg-query -W -f='${binary:Package}\n' | grep -wo "$pkg_name" | head -1)
    if [ "$is_installed" = "$pkg_name" ] ; then
        echo "$pkg_name is already installed"
        return $RETURN_SUCCESS # Installed
    else
        if [ $to_install -eq 1 ] ; then
            echo "Installing the package: $pkg_name"
            echo $PASSWORD | sudo -S apt install $pkg_name -y
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

#checkRepoIsCloned <repo> <path> {(opt)to be cloned or not} {(opt)to clone recursively} {(opt)
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
    repo_name="${repo##*/}"
    path=$2
    to_cloned=0
    if [ $# -gt 2 ] ; then
        to_cloned=$3
    fi

    is_recursive=0
    if [ $# -gt 3 ] ; then
       is_recursive=$4 
    fi

    repo_hosting_platform="$REPO_HOSTING_PLATFORM"
    if [ $# -gt 4 ] ; then
        repo_hosting_platform=$5
    fi

    findFileOrDir "$repo_name" "$path" "d" 1
    is_dir_present=$?
    if [ "$is_dir_present" -eq $RETURN_FAILURE ] ; then
        if [ $to_cloned -eq 1 ] ; then
            if [ $is_recursive -eq 1 ] ; then
                cd $path
                git clone --recurse-submodules "$repo_hosting_platform/$repo.git" 
                cd $ORIGINAL_DIR
            else
                cd $path
                git clone "$repo_hosting_platform/$repo.git"
                cd $ORIGINAL_DIR
            fi
            
            checkStatus 0 "Unsuccessful in cloning the repo: $repo_name"
            status=$?
            if [ $status -eq 0 ] ; then
                echo "Successfully cloned the repo: $repo_name"
                return $RETURN_SUCCESS #Clonned successfully
            fi
        else
            echo "Repo : $repo_name is not present."
        fi
    else
        echo "Repo: $repo_name is already present"
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
            cp $ORIGINAL_DIR/my_vimrc $HOME/
            checkStatus 1
            mv $HOME/my_vimrc $HOME/.vimrc
            checkStatus 1
        else
            echo "My vimrc is already present"
            return $RETURN_SUCCESS
        fi
    else
        cp $ORIGINAL_DIR/my_vimrc $HOME/
        checkStatus 1
        mv $HOME/my_vimrc $HOME/.vimrc
        checkStatus 1
    fi

    echo "My vimrc setup is done!!!"
    return $RETURN_SUCCESS
}

function checkVimVersion {

    ver_num=$(vim --version | head -n 1 | awk '{print $5}')
    checkStatus 1
    if (( $(echo "$ver_num >= 9.1" | bc -l) )) ; then
        return $RETURN_SUCCESS
    fi

    return $RETURN_FAILURE
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
        echo ".vim directory is already present for plugins"
    fi
    return $RETURN_SUCCESS
}



function setUpYCM { 
   
    checkRepoIsCloned "ycm-core/YouCompleteMe" "$HOME/.vim/pack/default/opt" 1 1

    checkPkgIsInstalled "build-essential" 1
    checkPkgIsInstalled "cmake" 1
    checkPkgIsInstalled "python3-dev" 1
    
    cd ~/.vim/pack/default/opt/YouCompleteMe

    python3 install.py --clangd-completer
    checkStatus 0 "Failure!!! YCM is not configured for C/C++ projects"
    status=$?
    
    echo "YCM is configured"
    cd $ORIGINAL_DIR
    return $status
}


function setUpStarscope {
    
    checkPkgIsInstalled "ruby-dev" 1
    sudo gem install starscope
    checkStatus 0 "Unsuccessful in installing starscope"
    status=$?
    return $status

}

function setUpCodeQuery {
    req_packages=(
        "build-essential"
        "g++"
        "git"
        "cmake"
        "ninja-build"
        "sqlite3"
        "libsqlite3-dev"
        "cscope"
        "universal-ctags"
    )

    gui_packages=(
        "qtcreator"
        "qtbase5-dev"
        "qt5-qmake"
        "qttools5-dev-tools"
        "qttools5-dev"
    )

    for pkg in "${req_packages[@]}"
    do
        checkPkgIsInstalled "$pkg" 1
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

    findFileOrDir "codequery" "$HOME/tools" "d" 
    is_dir_present=$?
    if [ "$is_dir_present" -eq $RETURN_FAILURE ] ; then
        mkdir -p $HOME/tools/codequery
    fi

    cd $ORIGINAL_DIR/codequery

    if [ "$CODEQUERY_GUI" = "YES" ] ; then
        for pkg in "${gui_packages[$i]}" 
        do
            checkPkgIsInstalled "$pkg" 1
            status=$?

            if [ $status -ne 0 ] ; then
                return $RETURN_FAILURE
            fi
        done
        cmake -DCMAKE_INSTALL_PREFIX="$HOME/tools/codequery" -G Ninja -DBUILD_QT5=ON -S . -B build
    else
        cmake -DCMAKE_INSTALL_PREFIX="$HOME/tools/codequery" -G Ninja -DNO_GUI=ON -S . -B build
    fi

    cmake --build build
    status=$?
    checkStatus 0 "Unsuccessful in building the codequery"
    if [ $status -ne 0 ] ; then
        return $RETURN_FAILURE
    fi

    echo $PASSWORD | sudo -S cmake --install build
    status=$?
    checkStatus 0 "Unsuccessful in installing the codequery"
    if [ $status -ne 0 ] ; then
        return $RETURN_FAILURE
    fi
    
    return $RETURN_SUCCESS
}


function setUpVimCodeQuery {
    
    checkRepoIsCloned "Shougo/unite.vim" "$HOME/.vim/pack/default/opt" 1
    status=$?
    if [ $status -ne 0 ] ; then
        return $RETURN_FAILURE
    fi

    checkRepoIsCloned "devjoe/vim-codequery" "$HOME/.vim/pack/default/opt" 1
    status=$?
    if [ $status -ne 0 ] ; then
        return $RETURN_FAILURE
    fi

    return $RETURN_SUCCESS
}

BANNER=$(<banner.txt)
echo "$BANNER" 


#   Start the setup
environment_variable=(
    "ORIGINAL_DIR"
    "REPO_HOSTING_PLATFORM"
    "CODEQUERY_GUI"
    "INSTALL_YCM"
    "INSTALL_CODEQUERY"
    "INSTALL_VIM_CODEQUERY"
)

echo "Do you want to create the template for env_variable file to configure you setup?"
choise=""
echo "yes : To create the template and quit to configure it"
echo "no  : To move on with configuration"
read -p "Your choise : " choise

if [ "$choise" = "yes" ] ; then
    findFileOrDir "env_variable" "$PWD" "f"
    find_status=$?
    if [ $find_status -eq $RETURN_SUCCESS ] ; then
       rm $PWD/env_variable
    fi
    touch $PWD/env_variable

    
    for env_var in "${environment_variable[@]}";
    do
       echo "$env_var=" >> $PWD/env_variable
    done

    exit $RETURN_SUCCESS
elif [ "$choise" = "no" ] ; then
    
    findFileOrDir "env_variable" "$PWD" "f" 
    status=$?
    if [ "$status" -eq $RETURN_FAILURE ] ; then
        echo "env_variable is not present"
        echo "Create the template and configure it first"
        exit $RETURN_FAILURE
    fi

else

    echo "Error: Entered unknown choise"
    exit $RETURN_FAILURE
fi

source "$PWD/env_variable"
declare -A env_var_map=(
    ["ORIGINAL_DIR"]="$ORIGINAL_DIR"
    ["REPO_HOSTING_PLATFORM"]="$REPO_HOSTING_PLATFORM"
    ["CODEQUERY_GUI"]="$CODEQUERY_GUI"
    ["INSTALL_YCM"]="$INSTALL_YCM"
    ["INSTALL_CODEQUERY"]="$INSTALL_CODEQUERY"
    ["INSTALL_VIM_CODEQUERY"]="$INSTALL_VIM_CODEQUERY"
)

echo "Are you sure about the below configuration?"
for env_var in "${!env_var_map[@]}";
do
   echo "$env_var : ${env_var_map["$env_var"]}"
done

choise=""
echo "yes : To move on with the current configuration for setup"
echo "no  : To quit the setup"
read -p "Your choise : " choise

if [ "$choise" = "no" ] ; then
    exit $RETURN_SUCCESS
elif [ "$choise" = "yes" ] ; then
    echo "Moving forward with configuration"
else
    echo "Error: Entered unknown choice" 
    exit $RETURN_FAILURE
fi

read -sp "Your password to executing requiring sudo access:" PASSWORD
echo ""
echo "$PASSWORD"

findFileOrDir "status.txt" "$ORIGINAL_DIR" "f"
find_status=$?
if [ $find_status -eq $RETURN_SUCCESS ] ; then
    rm $ORIGINAL_DIR/status.txt
fi
# Setting the .vimrc first
setUpVimrc
status=$?
logStatus "Setting up .virmc: " $status 

# Setting up the plugin directory
setUpPluginDir
status=$?
logStatus "Setting up Plugin directory: " $status 

touch status.txt

# Installing packages

for pkg in "${essential_pkg[@]}"
do
    checkPkgIsInstalled "$pkg" 1
    status=$?
    logStatus "Installing $pkg: " $status 
done

# Installing the plugins
for plugins in "${essential_plugins[@]}"
do
    checkRepoIsCloned "$plugins" "$HOME/.vim/pack/default/start" 1
    status=$?
    logStatus "Installing $plugins: " $status 
done

for plugins in "${optional_plugins[@]}"
do
    checkRepoIsCloned "$plugins" "$HOME/.vim/pack/default/opt" 1
    status=$?
    logStatus "Setting up $plugins: " $status 
done

if [ "$INSTALL_YCM" = "YES" ] ; then
    checkVimVersion
    status=$?
    if [ $status -eq $RETURN_SUCCESS ] ; then
        setUpYCM
        status=$?
        logStatus "Setting up YCM: " $status
    else
        logStatus "Setting up YCM: " $RETURN_FAILURE
    fi
fi

if [ "$INSTALL_CODEQUERY" = "YES" ] ; then
    setUpCodeQuery
    status=$?
    logStatus "Setting up codequery: " $status
    setUpStarscope 
    status=$?
    logStatus "Setting up starscope: " $status
fi

if [ "$INSTALL_VIM_CODEQUERY" = "YES" ] ; then
    setUpVimCodeQuery
    status=$?
    logStatus "Setting up vim-codequery: " $status
fi

echo "==================================================================="
echo "Configuration of Dev status is complete"
echo "==================================================================="
echo "Status of the configuration"
echo "+++++++++++++++++++++++++++++++++++++"
cat $ORIGINAL_DIR/status.txt
