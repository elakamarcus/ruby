require 'netaddr'
require 'CSV'
require 'nexpose'

$nsc = Nexpose::Connection.new('nexposeServer', 'nxadmin', "nxadmin")
$nsc.login

#Check if tag exist, return true||false
def isExist(name)
    tags = $nsc.list_tags
    if tags.find{|t| t.name == name}
        return true
    else
        return false
    end
end

#Find the ID of a tag.
def findTagID(name)
    tags = $nsc.list_tags
    if tags.find{|tag| tag.name == name}
        return tag.id
    else
        puts "Unable to find existing tag ID?"
    end
end

#for cidr notation
def netcidr (addr1, name)
    cidr = NetAddr::CIDR.create(addr1)
    #this will have to be generalised, depending on number of columns
    puts "CIDR = #{cidr}"
    puts "#{name} = #{cidr.first} -> #{cidr.last}"
    criterion = Nexpose::Tag::Criterion.new('IP_RANGE', 'IN', [cidr.first,cidr.last])
    criteria = Nexpose::Tag::Criteria.new(criterion)
    #check if tag exist, to either create new or update existing.
    if isExist(name)
        id = findTagID(name)
        tag = Nexpose::Tag.load($nsc, id)
    else
        tag = Nexpose::Tag.new(name, Nexpose::Tag::Type::Generic::LOCATION)
    end
    puts "Critera: #{criteria}"
end

#for defined start-end
def netrange (addr1, addr2, name)
    #this will have to be generalised, depending on number of columns
    puts "#{name} = #{addr1} -> #{addr2}"
    criterion = Nexpose::Tag::Criterion.new('IP_RANGE', 'IN', [addr1,addr2])
    criteria = Nexpose::Tag::Criteria.new(criterion)
    puts "Critera: #{criteria}"
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

#read the headers into ... headers :-)
headers = CSV.open('filename', 'r') { |a| a.first }

#check if too many columns. 3 is desirable.
if headers[3]
    puts "Too many columns in file. Try again."
    $nsc.logout
    exit
end

=begin Was nice for testing
puts "Headers"
puts "first: #{headers[0]}"
puts "second: #{headers[1]}"
puts "third: #{headers[2]}"
=end

CSV.foreach('filename', {:headers => true, :encoding => "ISO-8859-15:UTF-8"}) do |row|
if testIP(row[headers[0]])
    #check if string contains "/"
    if row[headers[0]]["/"]
        netcidr(row[headers[0]], row[headers[2]])
    else
        if testIP(row[headers[1]])
            netrange(row[headers[0]], row[headers[1]], row[headers[2]])
        else
            next
        end
    end
else
    puts "Expecting IPv4, either all octects or CIDR-notation on last octet."
    next
end
=begin
if $nsc.session_id
    $nsc.logout
end
=end
end