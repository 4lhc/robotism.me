#!/bin/bash
#based on https://github.com/andimiya/deploy-jekyll-master/blob/master/deploy-script.sh#L9

#Script is written for a Jekyll Site hosted on Github Pages, it should be modified if using it for a personal Github Pages site

#Make sure you have a master branch on your repo, create one if you don't
#Put this script at the root of your development branch
#Run the script while on your development branch only
#It will build your site and publish only the built files to your master branch where Github Pages knows to serve the files

rm -rf _site
git clone -b master `git config remote.origin.url` _site
bundle exec jekyll build
cd _site
touch CNAME
echo "robotism.me" >> CNAME
git add .
git commit -m "Scripted build to master"
git push
