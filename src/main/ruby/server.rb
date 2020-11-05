require 'socket'
require 'time'

server = TCPServer.open('0.0.0.0', 44010)

print "Server running on 0.0.0.0:44010"

while connection = server.accept
  print "connection accepted"
  
  body = "Hello from ruby!"

  head = "HTTP/1.1 200\r\n" \
  "Date: #{Time.now.httpdate}\r\n" \
  "Content-Length: #{body.length.to_s}\r\n" 

  # 1
  connection.write head

  # 2
  connection.write "\r\n"

  # 3
  connection.write body

  connection.close 
end