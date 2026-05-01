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
  linux-image-amd64
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
group 'sudo' do
  members 'bpolozov'
  action :create
end
user = 'bpolozov'
home = "/home/#{user}"

directory "#{home}/.ssh" do
  owner user
  group user
  mode '0700'
end

file "#{home}/.ssh/authorized_keys" do
  content "
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFrILPKQbrtDn7FwtZNIiHkxPV00eLqkZagv7ZLOzIZ bpolozov@workstation.east.local
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJPpkHs0EiTguLcbcr+Sh3Z7ntSmUTKo3qfVa5s2nF4v your@email.com"
  owner user
  group user
  mode '0600'
end

include_recipe 'common::grub'