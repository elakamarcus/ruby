require 'netaddr'
require 'CSV'

#for cidr notation
def netcidr (addr1, name)
    cidr = NetAddr::CIDR.create(addr1)
    #this will have to be generalised, depending on number of columns
    puts "CIDR = #{cidr}"
    puts "First: #{cidr.first}"
    puts "Last: #{cidr.last}"
    puts "Location: #{name}"
end

#for defined start-end
def netrange (addr1, addr2, name)
    #this will have to be generalised, depending on number of columns
    puts "First: #{addr1}"
    puts "Last: #{addr2}"
    puts "Location: #{name}"
end

#read the headers into ... headers :-)
headers = CSV.open('filename', 'r') { |a| a.first }

#check if too many columns. 3 is desirable.
if headers[3]
    puts "Too many columns in file. Try again"
    exit
end

puts "Headers"
puts "first: #{headers[0]}"
puts "second: #{headers[1]}"
puts "third: #{headers[2]}"

puts ""
puts ""

CSV.foreach('filename', {:headers => true, :encoding => "ISO-8859-15:UTF-8"}) do |row|
    #check if string contains "/"
    if row[headers[0]]["/"]
        netcidr(row[headers[0]], row[headers[2]])
    else
        netrange(row[headers[0]], row[headers[1]], row[headers[2]])
    end
end