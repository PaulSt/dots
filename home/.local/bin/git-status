#!/bin/bash

p_flag=''
dir=''

print_usage() {
    printf "Search for git repos, show status and offer push if needed.
    Use -p flag to check if pull is required.
    Use -d {dir} flag to define directory for the search, else $HOME is used."
}

while getopts 'hpd:' flag; do
    case "${flag}" in
        p) p_flag='true' ;;
        d) dir="${OPTARG}" ;;
        h) print_usage
            exit 1;;
        *) print_usage
            exit 1 ;;
    esac
done

# No directory has been provided, use home
if [ -z "$dir" ]
then
    dir=$HOME #or default to current dir: "`pwd`"
fi

function recursedir()
{
    # Make sure directory ends with "/"
    if [[ $1 != */ ]]
    then
        dir="$1/*"
    else
        dir="$1*"
    fi

    # Loop all sub-directories
    for f in $dir
    do
        # Only interested in directories
        [ -d "${f}" ] || continue


        # Check if directory is a git repository
        if [ -d "$f/.git" ]
        then
            echo -en "\033[0;35m"
            echo "${f}"
            echo -en "\033[0m"
            mod=0
            cd $f

            # Check for modified files
            if [ $(git status | grep modified -c) -ne 0 ]
            then
                mod=1
                echo -en "\033[0;31m"
                echo "Modified files"
                echo -en "\033[0m"
            fi

            # Check for untracked files
            if [ $(git status | grep Untracked -c) -ne 0 ]
            then
                mod=1
                echo -en "\033[0;31m"
                echo "Untracked files"
                echo -en "\033[0m"
            fi

            # Check for commits
            if [ $(git status | grep ahead -c) -ne 0 ]
            then
                mod=1
                echo -en "\033[0;31m"
                echo "Needs Push"
                echo -en "\033[0m"
                read -r -p "Do you want to push? [Y/n] " response
                if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$|^$ ]]
                then
                    $(git push)
                else
                    echo "ok"
                fi
            fi

            # Check if up to date
            #if [ "$p_flag" == true ] ; then
            $(git remote update > /dev/null)
            if [ $(git status | grep behind -c) -ne 0 ]
            then
                mod=1
                echo -en "\033[0;31m"
                echo "Pull available"
                echo -en "\033[0m"
                read -r -p "Do you want to pull? [Y/n] " response
                if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$|^$ ]]
                then
                    $(git pull)
                else
                    echo "ok"
                fi
            fi
            #fi

            # Check if everything is peachy keen
            if [ $mod -eq 0 ]
            then
                echo "Nothing to commit"
            fi

            cd ../
            echo
        else
            recursedir $f
        fi
    done
}

recursedir $dir
