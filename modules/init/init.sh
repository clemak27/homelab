#!/bin/bash

project_dir=/var/home/clemens/Projects

# fix permissions
# ignition creates the keys.txt file, but the dir is owned by root
chown -R clemens:clemens /var/home/clemens/.config

# git repo
if [ ! -d "$project_dir/homelab" ]
then
  echo "Checking out homelab repo..."
  mkdir -p $project_dir
  cd $project_dir && git clone https://github.com/clemak27/homelab
  cd $project_dir/homelab && git checkout homelab2
  chown -R clemens:clemens $project_dir
  echo "Done"
fi

# su clemens -c "cd $project_dir/homelab/services && ./deploy.sh"
