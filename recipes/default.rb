include_recipe 'common::install_gems' unless node['roles'].include? "workstation"
include_recipe 'common::install_cacerts'
include_recipe 'common::systemd_resolved'
include_recipe 'common::chef_client'

%w(
  htop
  tree
  tcpdump
  fish
  vim
  gnupg
  wget
  lsb-release
  curl
  jq
).each do |pkg|
  package pkg do
    action :install
  end
end

user 'bpolozov' do
  shell '/bin/bash'
  action :create
end
