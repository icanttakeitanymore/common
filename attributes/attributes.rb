default['common']['gems'] = {
  "vault": '0.18.2', # override vaults 0.18.2 with path encoding bug
}

default['openbao']['url'] = 'https://vault.east.local'
default['kernel']['image'] = 'linux-image-6.12.73+deb13-amd64'