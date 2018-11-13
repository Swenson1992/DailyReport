#!/bin/bash
# Author: it.song
rm -f changelog.md

while true; do

    echo '[更新日志]' >> changelog.md
    GIT_PAGER=cat git log --no-merges --date=short  --pretty=format:'- %ad (%an) %s -> [view commit](https://github.com/songjian925/DailyReport/commit/%H)' >> changelog.md
    break
done
echo "DONE."
