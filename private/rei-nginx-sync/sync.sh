#!/bin/bash

# Clone the Git repository
git clone "https://github.com/rk-webdesign/tales.git"

# Your rsync command to sync data to the other container
rsync -r --delete /home/rei/git/tales/website/ /tmp/new/

