require_relative 'hetzner'
require 'cloudflare'

connection = Cloudflare.connect key: ENV['CLOUDFLARE_KEY'], email: ENV['CLOUDFLARE_EMAIL']
zone = connection.zones.find_by_name ENV['DNS_ZONE']

Hetzner::SERVERS.each do |server|
  puts "Creating dns record for #{server.inspect}"
  zone.dns_records.post({
    type: "A",
    name: server[:name],
    content: server[:ip],
    ttl: 240,
    proxied: false
  }.to_json, content_type: 'application/json')

  # wildcard entry for openshift_master_default_subdomain
  zone.dns_records.post({
    type: "A",
    name: '*.apps',
    content: server[:ip],
    ttl: 240,
    proxied: false
  }.to_json, content_type: 'application/json')
end
