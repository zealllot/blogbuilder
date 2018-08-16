#!/usr/bin/env bash

set -e

export remote_user=
export remote_host=
export posts_directory=
export repository=

while true
do
    echo -e "Title: （'\ / : * ? \" < > |' are not allowed)"
    read title

    echo -e "Tags: (using space to separate tags)"
    read tags
    tags="\""$tags"\""
    tags=${tags// /\",\"}
    echo $tags

    date=`date "+%FT%T+08:00"`
    echo $date

    sed -i '' '1i \
    +++;title = '"\"$title\""';date = '"$date"';tags = ['"$tags"'];draft = false;+++;
    ' template.md

    filename=${title// /_}
    sed -e '1 s/;/\'$'\n/g' template.md > $filename.md

    echo "1 ------ add tag and rename"

    if [ $? -eq 0 ]
    then
        break
    fi
    echo "The title is not in the right format.Please try again."
done


scp $filename.md $remote_user@$remote_host:$posts_directory
echo "2 ------ upload and deploy"

if [ $? -ne 0 ]
then
    echo "Bad network ... Please try again later."
else
    cd posts
    if [ $? -ne 0 ]
    then
        git clone $repository
        cd posts
    fi

    git pull --rebase

    mv ../$filename.md ./

    git add $filename.md
    git commit -m "$title"
    git push origin master

    echo "3 ------ backup"

    : > ../template.md
    echo "4 ------ clear"
fi 

