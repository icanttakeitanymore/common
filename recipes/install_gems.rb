#
# сука блять,
# мы не можем заменить версию vault либы из-за того что шеф от нее зависит,
# по этому всегда считаем чексуму
# 15c15
# <       path.b.gsub(%r!([^a-zA-Z0-9_.-/]+)!) { |m|
# ---
# >       path.b.gsub(%r!([^a-zA-Z0-9_./\-]+)!) { |m|

chef_gem 'vault' do
  version '0.18.2'
  compile_time true
  action :purge
  not_if do
    file_path = "/opt/cinc/embedded/lib/ruby/gems/3.1.0/gems/vault-0.18.2/lib/vault/encode.rb"
    expected_checksum = "bad1e19728696b5ad67890cd1e589af38dfea58fb98a20a54d8e10d6e6920c08"
    File.exist?(file_path) && Chef::Digester.checksum_for_file(file_path) == expected_checksum
  end
end

node['common']['gems'].each do |gem, version|
  chef_gem gem do
    version version
    options '--local'
    source "/var/cinc/cache/cookbooks/common/files/gems/#{gem}-#{version}.gem"
    compile_time true
  end
end