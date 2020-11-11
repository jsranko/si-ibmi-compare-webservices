require 'socket'
require 'time'
require 'json'

def getFileName (fileName, configurationFile)

  file = open(configurationFile)
  json = file.read
  rootNode = JSON.parse(json)
  
  return rootNode["files"][fileName]
end

def getFileData (fileName)

  unless fileName.nil?
    file = open(fileName)
    json = file.read
    rootNode = JSON.parse(json)
  
    return rootNode  
  end

end

server = TCPServer.open('0.0.0.0', 44010)

print "Server running on 0.0.0.0:44010"

while connection = server.accept
  puts "connection accepted"
  
  request = connection.gets
  
  paramstring = request.split('?')[1]     
  paramstring = paramstring.split(' ')[0] 
  params  = paramstring.split('&')
  
  body = "Hello from ruby"
  
  for param in params do
     key, value = param.split('=')
     if key == "fileSize"
   		fileName = getFileName(value, "config.json")
        data = getFileData(fileName)
   	 end
  end
  
  unless data.nil?
    body = JSON.dump(data)
  end  
 
  puts "hier geht es weiter ..."
  
  head = "HTTP/1.1 200\r\n" \
  "Date: #{Time.now.httpdate}\r\n" \
  "Content-Type: application/json\r\n" \
  "Content-Length: #{body.length.to_s}\r\n" 

  # 1
  connection.write head

  # 2
  connection.write "\r\n"

  # 3
  connection.write body

  connection.close 
end
