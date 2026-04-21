require 'chef/resource'

class CaCeritifcates < Chef::Resource
  resource_name :install_ca_certificates
  provides :install_ca_certificates

  default_action :run

  property :compile_time, [true, false],
           default: true, desired_state: false

  def after_created
    if compile_time
      Array(action).each do |action|
        run_action(action)
      end
    end
  end

  action :run do
    cfg = nil
    case node['platform']
    when 'centos', 'fedora', 'oracle'
      cfg =  {
        cmd: 'update-ca-trust',
        dir: '/etc/pki/ca-trust/source/anchors',
        ca_bundle: '/etc/ssl/cert.pem',
      }
    when 'ubuntu', 'debian', 'kali'
    cfg =   {
        cmd: 'update-ca-certificates',
        dir: '/usr/local/share/ca-certificates',
        ca_bundle: '/etc/ssl/certs/ca-certificates.crt',
      }
    package 'ca-certificates'
    end


    remote_directory cfg[:dir] do
      source 'cacerts'
      owner 'root'
      group 'root'
      mode '0755'
      files_owner 'root'
      files_group 'root'
      files_mode '0644'
      action :create
      notifies :run, 'execute[update-ca-certificates]', :immediately
    end


    execute 'update-ca-certificates' do
      environment ({ 'PATH' => "#{ENV['PATH']}:/usr/sbin" })
      command cfg[:cmd]
      action :nothing
    end

    link '/opt/cinc/embedded/ssl/cert.pem' do
      to cfg[:ca_bundle]
    end
  end
end