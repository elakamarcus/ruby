# ruby

simple ruby scripts to help working with Nexpose Rapid7.

## compatability

The code is designed for Ruby 2.3.0 and Nexpose 5.1.0 (gem).

## scripts

_nexpose_tags_from_ip_

- Import a CSV file with tag name and ip address or range, either cider or (being, end):
```
dmz, 172.16.45.0/32
vip, 172.16.47.0/24
drones, 10.0.0.0, 10.0.10.0
```
_parseIPrange_
- Just a test script to verify the above input data

_scanstatuscsv_
- Get the status of all schedule scans and export to a csv. as simple as that.