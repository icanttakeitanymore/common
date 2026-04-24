systemd_unit 'chef-client.service' do
  content({
            Unit: {
              Description: 'Chef Client',
              Documentation: ['https://docs.chef.io/chef_client/'],
              Wants: 'network-online.target',
              After: 'network-online.target',
            },
            Service: {
              Type: 'oneshot',
              ExecStart: '/usr/bin/chef-client',
              # чтобы не считался "мертвым" после выполнения
              RemainAfterExit: false,
            },
          })

  action [:create]
end

systemd_unit 'chef-client.timer' do
  content({
            Unit: {
              Description: 'Run Chef Client periodically',
            },
            Timer: {
              OnBootSec: '30s', # аналог -s 30
              OnUnitActiveSec: '100s', # аналог -i 100

              # jitter
              RandomizedDelaySec: '30s',

              AccuracySec: '1s',
              Persistent: true,
              Unit: 'chef-client.service',
            },
            Install: {
              WantedBy: 'timers.target',
            },
          })

  action [:create, :enable, :start]
end
