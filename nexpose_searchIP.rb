# Nexpose search IP return tag, asset etc.

require 'netaddr'
require 'nexpose'

# connect to Nexpose Rapid7 scanner:
=begin
host = "127.0.0.1"
user = "nxadmin"
pass = "nxadmin" # in newer versions, this has to be changed on first boot

$nsc = Nexpose::Connection.new(host, user, pass)
$nsc.login
at_exit { $nsc.logout }

=end

def SearchTag(addr)
    tag = "tag"
    return tag

=begin
    tags = $nsc.list_tags
    for { |t| in tags }
        if tag.search_criteria.criteria.map(&:value).flatten.uniq.include?(cidr.nth(0))
        return tag
end
=end
def SearchSite(addr)
    site = "Site"
    return site
end

def testIP(addr)
    #Need to improve the regex, but no time..
    rex1 = /\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}.\d{1,2}/
    rex2 = /\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}/
        if rex1.match(addr) || rex2.match(addr)
            return true
        else
            return false
        end
    end

def getAddr(addr)
    if testIP(addr)
        #check if string contains "/"
        if addr.to_s.include? "/"
            # cidr-notation spotted, ignoring second column
            cidr = NetAddr::IPv4Net.parse(addr1)
            return cidr.nth(0)
        else
            return addr
        end
    else
        puts "Expecting IPv4, either all octects or CIDR-notation on last octet."
        next
    end
end

if argv[1]
    SearchTag(getAddr(addr))
    SearchSite(getAddr(addr))
else   
    puts "Execute with single IP or Cidr as parameter\nE.g. 192.168.0.1/24 or 192.168.10.45"
end

