require 'socket'
 
host = '127.0.0.1'
port = 8029
path = "/js/sploit.js"

# This is the HTTP request we send to fetch a file
request = "GET #{path} HTTP/1.0\r\n\r\n"

socket = TCPSocket.open(host,port)  # Connect to server
socket.print(request)               # Send request
response = socket.read              # Read complete response
# Split response at first blank line into headers and body
headers,body = response.split("\r\n\r\n", 2) 
printf("Headers: %s \n\n",headers)                          # And display it
printf("Body: %s\n\n",body)                          # And display it
