require_relative 'hetzner'
require 'hetzner-bootstrap'

module Hetzner
  class Server
    def self.recreate(*args)
      new(*args).bootstrap
    end

    def initialize(id:, ip:,
                   install_image_template: 'files/centos.installimage',
                   ssh_key: '~/.ssh/a-ads_terraform.pub',
                   hostname: 'centos-7.4-minimal')
      @id = id
      @ip = ip
      @install_image_template = install_image_template
      @ssh_key = ssh_key
      @hostname = hostname

      @api = Hetzner::API.new(
        ENV['ROBOT_USER'],
        ENV['ROBOT_PASSWORD']
      )

      @worker = Hetzner::Bootstrap.new(api: @api)
    end

    def bootstrap
      fail 'server id is wrong!' if @id != server_info['server_number']
      @worker << {
        # hetzner server ip
        ip: server_info['server_ip'],

        # config file for installimage rescue mode utility
        template: File.read(@install_image_template),

        hostname: @hostname,

        # This key will be copied to server
        public_keys: @ssh_key,

        post_install_remote: 'sysctl dev.raid.speed_limit_max=10; pvcreate /dev/md2 -f',
      }
      @worker.bootstrap!
    end

 private
   
    def server_info
      @server_info ||= @api.server?(@ip)
      fail "api error: #{@server_info.response}" if @server_info.code.to_i > 299
      @server_info['server']
    end
  end
end

Thread.abort_on_exception = true
threads = []

Hetzner::SERVERS.each do |server|
  threads << Thread.new do
    Hetzner::Server.recreate(ip: server[:ip], id: server[:id], hostname: server[:name])
  end
end

threads.each(&:join)
