package 'systemd-resolved'

template '/etc/systemd/resolved.conf' do
  source 'resolved.conf.erb'
  notifies :restart, 'service[systemd-resolved]', :immediately
end

service 'systemd-resolved' do
  action :nothing
end
