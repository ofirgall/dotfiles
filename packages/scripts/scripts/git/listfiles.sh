#!/bin/zsh

## Installation:
# - make a file, called `listfiles` in a directory, covered by your $PATH variable;
# - `chmod a+x` this file.

if [ $# -eq 0 ]
then
    COMMIT_FROM="HEAD~"
    COMMIT_TO="HEAD"
elif [ $# -eq 1 ]
then
    COMMIT_FROM="$1~"
    COMMIT_TO="$1"
elif [ $# -eq 2 ]
then
    COMMIT_FROM="$1"
    COMMIT_TO="$2";
else
    echo 'Usage: [<first commit id> [<last commit id>]]'
    echo 'Two arguments max!';
    exit
fi

git diff --name-only --relative $COMMIT_FROM $COMMIT_TO | fgrep -v '/vendor/' | sort > /tmp/file_list_git
find . -type f | sed 's#^./##' | sort > /tmp/file_list_all
FLIST=`comm -12 /tmp/file_list_git /tmp/file_list_all`

echo $FLIST
