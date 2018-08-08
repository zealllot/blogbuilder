#!/usr/bin/env bash

remote_user=
remote_host=
posts_directory=

set -e

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

    if [ $? -eq 0 ]
    then
        break
    fi
    echo "The title is not in the right format.Please try again."
done


scp $filename.md $remote_user@$remote_host:$posts_directory
if [ $? -ne 0 ]
then
    echo "Bad network ... Please try again later."
else
    cd posts
    if [ $? -ne 0 ]
    then
        git clone git@github.com:zealllot/posts.git
        cd posts
    fi

    mv ../$filename.md ./

    git add $filename.md
    git commit -m "$title"
    git push origin master

    echo "" > ../template.md
fi 

