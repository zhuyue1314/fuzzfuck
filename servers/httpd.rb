require 'socket'

htdocs = "fuzzfront";
host = "127.0.0.1"
port = 8029

gs1 = TCPServer.open(host, port)

printf("http server is on %s:%s\n", host, port)

loop {
  Thread.start(gs1.accept) do |client|
    getReq = client.gets
    print(getReq,"\n")
    command,filePath,protocol = getReq.split(" ",3)
    if filePath == "/" #index file                                                                                                                                                                     
      print("recognized / returning index\n")
      filePath = "/index.html";
    end
    filePath = htdocs + filePath
    fileSize = 0 #initialize to 0                                                                                                                                                                      
    contentType = "text/html"
    body = ""
    if File.exists?(filePath) && File.file?(filePath) && File.readable?(filePath)
      printf("requested: %s\n", filePath)
      body = File.read(filePath)
      fileSize = File.size(filePath)
      ext = File.extname(filePath)
      case ext
      when ".js"
        contentType = "application/javascript"
      end
    end
    headers = <<DOC
HTTP/1.1 200 OK                                                                                                                                                                                        
Date: #{Time.now.ctime}                                                                                                                                                                                
Server: Apache/2.2.14 (Unix) mod_ssl/2.2.14 OpenSSL/0.9.8m DAV/2 PHP/5.3.2                                                                                                                             
Accept-Ranges: bytes                                                                                                                                                                                   
Content-Length: #{fileSize}
Connection: close                                                                                                                                                                                      
Content-Type: #{contentType}                                                                                                                                                                           
DOC
    client.puts headers + "\r\n\r\n" + body
    client.close
  end
}
