#!/bin/bash

project_dir=/var/home/clemens/Projects

if [ ! -d "$project_dir/homelab" ] 
then
  mkdir -p $project_dir
  cd $project_dir && git clone https://github.com/clemak27/homelab
  cd $project_dir/homelab && git checkout homelab2
  chown -R clemens:clemens $project_dir
fi
