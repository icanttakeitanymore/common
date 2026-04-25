cookbook_file '/etc/default/grub' do
  source 'etc/default/grub'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  notifies :run, 'execute[update-grub]'
end

execute 'update-grub' do
  command 'update-grub'
  action :nothing
end
