# Iocage Plugin Phoseum

Plugin for TrueNAS to run the personal photo museum components

## Getting and Setting

While running on the Jail Shell you will be to the get and set scripts suggested by TrueNAS but apparently they are not used.

This plugin will provide them at `/usr/local/bin/`

`phoseumset` and `phoseumget` are working scripts and can be used with:

 ### phoseumset options

 - webport [port_number]
 - apiport [port_number]
 - adduser [username] [Super|User] [password]
 - deluser [username]
 - serversecret

 ### phoseumget options

 - webport
 - apiport
 - listusers
 - deluser [username]
 - serversecret

For more information, please read documentation at [Phoseum Website](https://phoseum.org)
