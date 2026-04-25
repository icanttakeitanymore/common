include_recipe 'common::install_gems' unless node['roles'].include? "workstation"
include_recipe 'common::install_cacerts'
include_recipe 'common::systemd_resolved'
include_recipe 'common::chef_client'

%w(
  ncdu
  tree
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
  yq
  dracut-install
).each do |pkg|
  package pkg do
    action :install
  end
end

%w(
  os-prober
  nano
  dhcpcd-base
  laptop-detect
  eject

  installation-report
).each do |pkg|
package pkg do
  action :remove
end
end

user 'bpolozov' do
  shell '/bin/bash'
  action :create
end

include_recipe 'common::grub'