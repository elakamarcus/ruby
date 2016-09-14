require 'netaddr'
require 'CSV'

#for cidr notation
def netcidr (addr1, name)
    cidr = NetAddr::CIDR.create(addr1)
    #this will have to be generalised, depending on number of columns
    puts "CIDR = #{cidr}"
    puts "#{name} = #{cidr.first} -> #{cidr.last}"    
end

#for defined start-end
def netrange (addr1, addr2, name)
    #this will have to be generalised, depending on number of columns
    puts "#{name} = #{addr1} -> #{addr2}"
end

def testIP(addr)
#Need to improve the regex
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
    exit
end


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
end