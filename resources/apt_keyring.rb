provides :apt_keyring

property :url, String, name_property: true
property :keyring_path, String, default: lazy {
  "/etc/apt/keyrings/#{::File.basename(url, '.gpg')}.gpg"
}

action :create do
  directory '/etc/apt/keyrings' do
    recursive true
    mode '0755'
  end

  remote_file "/tmp/#{::File.basename(new_resource.keyring_path)}.asc" do
    source new_resource.url
    mode '0644'
  end

  execute "dearmor_#{new_resource.keyring_path}" do
    command lazy {
      "gpg --dearmor -o #{new_resource.keyring_path} /tmp/#{::File.basename(new_resource.keyring_path)}.asc"
    }
    creates new_resource.keyring_path
  end
end