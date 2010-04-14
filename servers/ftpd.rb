require 'socket'

host = "127.0.0.1"
port = 21
gs2 = TCPServer.open(host, port)

printf("ftp server is on %s:%s\n", host, port)

loop {

  Thread.start(gs2.accept) do |s|
    print("Got connection\n")
    remoteHost = s.peeraddr[3]
    s.print "200 #{host}:#{port} FTP server " \
             "(ftp proggy) ready.\r\n"
    while s.nil? == false and s.closed? == false
      request = s.gets
      command = request[0,4].downcase.strip
      rqarray = request.split
      message = rqarray.length > 2 ? rqarray[1..rqarray.length] : rqarray[1]
      print("Request: #{command}(#{message})\n")

      # commands supported
      #COMMANDS = %w[quit type user retr stor port cdup cwd dele rmd pwd list size syst site mkd]
      response = ""
      case command
        when "user"
          if message != 'anonymous'
            response = "331 Only anonymous user implemented"
          else
            response = "331 Please specify the password."
          end
        when /^pass/
          response = "230 OK, password not required"
        when "pwd"
          response = "257 \"#{Dir.pwd}\""
        when "syst"
          response = "215 UNIX fuzzFuck v1.0 "
        when "type"
          if message == "A"
            mode = "ascii"
            response = "200 Type set to ASCII"
          elsif message == "I"
            mode = "binary"
            response = "200 Type set to binary"
          end
        when "port"
          nums = message.split(',')
          pasvPort = nums[4].to_i * 256 + nums[5].to_i
          remoteHostMsg = nums[0..3].join('.')
          if datasocket
            datasocket.close
            datasocket = nil
          end
          datasocket = TCPSocket.new(remoteHost, pasvPort)
          response = "200 Passive connection established (#{pasvPort})"
        when "pasv"
          #response = "500 pasv not yet implemented"
	  randport = rand(65535 - 1024 - 80) + 1024
          datasocket = TCPServer.new(host, randport + 80)
          response = "227 Entering Passive Mode (#{host.split(".").join(",")},#{randport / 256},80)"
        when "list"
          #s.print "125 Opening ASCII mode data connection for file list\r\n"
          send_data(`ls -l`.split("\n").join(LBRK) << LBRK, mode, datasocket)
          #s.print `ls -l`.split("\n").join(LBRK) << "\r\n"
          response = "226 Transfer complete"
        when "size","mdtm","retr","mlsd" #because fuckem!
=begin
          if message == ""
            path = `pwd`
          else
            path = message
          end
          bytes = File.size(path)
=end
          #response = "#{path} #{bytes}"
          response = "550 Could not get file size"
        when "cwd"
          response = "250 Directory changed to " << Dir.pwd
        when "quit"
          response = "221 L8r"
          break #should get out of the while loop
        else
          response = "214 - Command: #{command}, not yet implemented"
      end
      print("Response:"+ response + "\n")
      s.print response + "\r\n"
    end
    
    s.close
  end
}

def send_data(data, mode, datasocket)
  bytes = 0
  begin
    # this is where we do ascii / binary modes, if we ever get that far
    data.each do |line|
      if mode == "binary"
        datasocket.syswrite(line)
      else
        datasocket.send(line, 0)
      end
      bytes += line.length
    end
  rescue Errno::EPIPE
    print("user aborted file transfer")  
    return quit
  else
    print("user got #{bytes} bytes")
  ensure
    datasocket.close
    datasocket = nil    
  end
  bytes
end
