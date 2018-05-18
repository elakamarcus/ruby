#testing the new version of NetAddr

require 'NetAddr'

IPFirst = "192.168.77.1"
IPLast  = "192.168.77.50"
IPRange = "192.168.88.0/18"

cidr = NetAddr::IPv4Net.parse(IPRange)
puts "first: #{cidr.nth(0)}\nlast: #{cidr.nth(cidr.len()-1)}"


# site = Site.new('SiteName', 'description?')