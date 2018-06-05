# consider remove netaddr, as NexposeAPI has IPRange
require 'netaddr'
require 'CSV'
require 'nexpose'
require 'highline/import'


=begin #############################
# Ask-part copied from MrPaul -- login method, instead of hardcoding username and password. It requires teh hihgline/import.
# https://github.com/misterpaul/NexposeRubyScripts/
=end ###############################

default_host = '127.0.0.1'
default_port = 3780
default_name = 'nxadmin'
default_password = "don't use default password!!!'"
default_file = 'file.csv'

host = ask('Enter the server name (host) for Nexpose: ') { |q| q.default = default_host }
user = ask('Enter your username: ') { |q| q.default = default_name }
pass = ask('Enter your password: ') { |q| q.echo = '*' }
$file = ask('Enter the csv $file to grab data from: ') { |q| q.default = default_file }

$nsc = Nexpose::Connection.new(host, user, pass)
$nsc.login
at_exit { $nsc.logout }

=begin #############################
# script prepared by Marcus Andersson, elakamarcus@github
# csv-file should be on the below form, notice lack of space:
# location,ipstart/range,ipend/NIL
# location1,ip1,ip2
# location2,range1
#
# if there is a cidr in second column, the third column is ignored.
# 2018-05-18: Update to match new version of NetAddr
# 2018-05-21: Have yet to verify the Nexpose API, current version 7.x, script originally made for 5.x
=end ###############################

# Check if tag exist, return true||false
def isExist(name)
    # put all tags into tags
    tags = $nsc.list_tags
    # search for tag matching name
    if tags.find{|t| t.name == name}
        return true
    else
        return false
    end
end

# Find the ID of a tag.
def findTagID(name)
    # put all tags into tags
    tags = $nsc.list_tags
    # if there is a tag with name
    if tags.find{|tag| tag.name == name}
        # put that tag into tagid
        tagid = tags.find{|t| t.name == name}
        return tagid.id
    else
        # this really should not happen, but i felt it funny to put here in case of!
        puts "Unable to find existing tag ID?"
    end
end

# for cidr notation, require NetAddr
def netcidr (name, addr1)
    # NetAddr 1.5.x
    # cidr = NetAddr::IPv4Net.extended(addr1)
    # cidr = CIDR.create(addr1)
    # this will break a cidr-notation into start and end IP:
    # puts "CIDR = #{cidr}"
    # puts "#{name} = #{cidr.first} -> #{cidr.last}"

    # NetAddr 2.x
    cidr = NetAddr::IPv4Net.parse(addr1)

    criterion = Nexpose::Tag::Criterion.new('IP_RANGE', 'IN_RANGE', [cidr.nth(0), cidr.nth(cird.len()-1)])
    criteria = Nexpose::Tag::Criteria.new(criterion)
    #check if tag exist, to either create new or update existing.
    if isExist(name)
        puts "Tag: #{name} exist. Loading tag."
        id = findTagID(name)
        tag = Nexpose::Tag.load($nsc, id)
        # Check if the IP already exist as a criteria. Even if it does seem to exist, it does not seem to be overwritten or cause issues.
        if tag.search_criteria.criteria.map(&:value).flatten.uniq.include?(cidr.nth(0))
            puts "#{addr} already in #{tag.name}"
        else
            tag.search_criteria = criteria
            # save the tag, after apply criteria
            tag.save($nsc)
        end
    else
        puts "Tag: #{name} does not exist. Creating tag."
        # create location tag.
        tag = Nexpose::Tag.new(name, Nexpose::Tag::Type::Generic::LOCATION)
        # below will update the critria of the tag.. instead of replacing.
        tag.search_criteria << criteria
        # save the tag, after apply criteria
        tag.save($nsc)
    end
    puts "Critera: #{criteria}"
    puts "name: #{name} cidr: #{addr1} => \n #{cidr.nth(0)} - #{cidr.nth(cidr.len()-1)}"
end

#for defined start-end
def netrange (name, addr1, addr2)
    #this will have to be generalised, depending on number of columns
    # puts "#{name} = #{addr1} -> #{addr2}"

    criterion = Nexpose::Tag::Criterion.new('IP_RANGE', 'IN_RANGE', [addr1, addr2])
    criteria = Nexpose::Tag::Criteria.new(criterion)
    # puts "Critera: #{criteria}"
    if isExist(name)
        puts "Tag: #{name} exist. Loading tag."
        #see findTagID function.
        id = findTagID(name)
        # tag exists, so loading tag. Seems can only load tag using ID, so function above is necessary.
        tag = Nexpose::Tag.load($nsc, id)
        #Check if IP already exist as Tag criteria (somehow this does not work for cidr?)
        if tag.search_criteria.criteria.map(&:value).flatten.uniq.include?(addr1)
            puts "#{addr1} already in #{tag.name}"
        else
            tag.search_criteria << criteria
            # save the tag, after apply criteria
            tag.save($nsc)
        end
    else
        puts "Tag: #{name} does not exist. Creating tag."
        tag = Nexpose::Tag.new(name, Nexpose::Tag::Type::Generic::LOCATION)
        tag.search_criteria = criteria
        # save the tag, after apply criteria
        tag.save($nsc)
    end
=end #########
    puts " Tag: #{name} = start: #{addr1} end: #{addr2}"
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

#default_file = 'file.csv'
#$file = ask('Enter the csv $file to grab data from: ') { |q| q.default = default_file }
$file = "filename.csv"
#read the headers into ... headers :-)
headers = CSV.open($file, 'r') { |a| a.first }

#check if too many columns. 3 is desirable.
if headers[3]
    puts "Too many columns in file. Try again."
    #$nsc.logout
    exit
end

CSV.foreach($file, {:headers => true, :encoding => "ISO-8859-15:UTF-8"}) do |row|
if testIP(row[headers[1]])
    #check if string contains "/"
    if row[headers[1]]["/"]
        # cidr-notation spotted, ignoring second column
        netcidr(row[headers[0]], row[headers[1]])
    else
        if testIP(row[headers[2]]) # if not cidr, then column 2 should be present.
            netrange(row[headers[0]], row[headers[1]], row[headers[2]])
        else
            # ... otherwise ignore and move on.
            puts "Row misformated. Skipping to next row."
            next
        end
    end
else
    puts "Expecting IPv4, either all octects or CIDR-notation on last octet."
    next
end