resource_name :node_metric
provides :node_metric

require 'timeout'

property :name, String, name_property: true
property :help, String, default: 'Custom node metric'
property :labels, Hash, default: {}

property :value_type, String,
         default: 'gauge',
         equal_to: %w[gauge counter summary histogram]

property :value, [Integer, Float, String, TrueClass, FalseClass, NilClass],
         required: false, default: nil

property :value_provider, [Proc, NilClass],
         required: false, default: nil

property :collector_path, String, default: '/var/lib/node_exporter'
property :filename_suffix, String

# scheduling
property :interval, Integer, default: 60

# execution mode
property :sync_cookbook, [TrueClass, FalseClass], default: true
property :runlist, String

property :timeout, Integer, default: 5

default_action :create

action :create do
  directory new_resource.collector_path do
    recursive true
    owner 'root'
    group 'root'
  end

  #
  # 1. Value calculation
  #
  unless new_resource.value_provider || !new_resource.value.nil?
    raise "Either 'value' or 'value_provider' must be provided for metric '#{new_resource.name}'"
  end

  val =
    begin
      if new_resource.value_provider
        Timeout.timeout(new_resource.timeout) do
          new_resource.value_provider.call
        end
      else
        new_resource.value
      end
    rescue Timeout::Error
      Chef::Log.error("Metric '#{new_resource.name}' timed out")
      -999
    rescue => e
      Chef::Log.error("Metric '#{new_resource.name}' failed: #{e.message}")
      -888
    end

  #
  # 2. Labels
  #
  lbl =
    if new_resource.labels.empty?
      ''
    else
      "{#{new_resource.labels.map { |k, v| "#{k}=\"#{v}\"" }.join(',')}}"
    end

  #
  # 3. Prometheus file content
  #
  content_str = <<~METRIC
    # HELP #{new_resource.name} #{new_resource.help}
    # TYPE #{new_resource.name} #{new_resource.value_type}
    #{new_resource.name}#{lbl} #{val}
  METRIC

  suffix_slug =
    new_resource.filename_suffix.nil? ? '' : "_#{new_resource.filename_suffix.gsub(/[^a-zA-Z0-9]+/, '_')}"

  filename = "#{new_resource.collector_path}/#{new_resource.name}#{suffix_slug}.prom"

  file filename do
    content content_str
    owner 'root'
    group 'root'
    mode '0644'
  end

  #
  # 4. systemd service
  #
  systemd_unit "node_metric_#{new_resource.name}.service" do
    content({
      Unit: {
        Description: "Node metric #{new_resource.name}"
      },
      Service: {
        Type: 'oneshot',
        ExecStart: if new_resource.sync_cookbook
          "/usr/bin/chef-client -o '#{new_resource.runlist}' --once"
        else
          "/usr/local/bin/node_metric_runner #{new_resource.name}"
        end
      }
    })
    action [:create, :enable]
  end

  #
  # 5. systemd timer (interval-based)
  #
  systemd_unit "node_metric_#{new_resource.name}.timer" do
    content({
      Unit: {
        Description: "Timer for node metric #{new_resource.name}"
      },
      Timer: {
        OnUnitActiveSec: "#{new_resource.interval}s",
        Persistent: true
      },
      Install: {
        WantedBy: 'timers.target'
      }
    })
    action [:create, :enable, :start]
  end
end


action :delete do
  suffix_slug =
    new_resource.filename_suffix.nil? ? '' : "_#{new_resource.filename_suffix.gsub(/[^a-zA-Z0-9]+/, '_')}"

  filename = "#{new_resource.collector_path}/#{new_resource.name}#{suffix_slug}.prom"

  file filename do
    action :delete
  end

  systemd_unit "node_metric_#{new_resource.name}.timer" do
    action [:stop, :disable, :delete]
  end

  systemd_unit "node_metric_#{new_resource.name}.service" do
    action [:stop, :disable, :delete]
  end
end