-- http server
sv=net.createServer(net.TCP)

local function sendHtml(c,url,body)
	if (url == "/") then
		c:send("HTTP/1.1 200 OK\r\n") 
		c:send("Connection: close\r\n\r\n")
		
		c:send("<html><body>")
		c:send("<h2>ESP8266</h2> ")
		majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
		c:send("<h3>NodeMCU "..majorVer.."."..minorVer.."."..devVer.." chipid:" .. chipid .. " flashid:" .. flashid .." flashsize:"..flashsize.."</h3>")				
		c:send("Uptime "..tmr.time().." s<br>")				
		c:send("Battery "..adc.readvdd33().." mV<br>")
		c:send("Heap Size:"..node.heap().." Bytes<br>")
		
		remain, used, total=file.fsinfo()
		c:send("File system info:")
		c:send("<ul><li>Total : "..total.." Bytes<li>Used : "..used.." Bytes<li>Remain: "..remain.." Bytes</ul>")
		
		c:send("File list:")
		c:send("<ul>")
		for k,v in pairs(file.list()) do
			c:send("<li>"..k.." "..v)
		end
		c:send("</ul>")
		
		c:send("AP  IP:" .. wifi.ap.getip() .. " MAC:" .. wifi.ap.getmac() .. "<br>")    
		
		if wifi.sta.getip() ~= nil then
			c:send("STA IP:" .. wifi.sta.getip() .. " MAC:" .. wifi.sta.getmac() .. "<br>")    
		end
		c:send("<form action=\"#\" method=\"post\">SSID:<input name=\"ssid\">Password:<input type=\"password\" name=\"password\"><button>Configure</button></form>")
		
		c:send("Message:<form action=\"#\" method=\"post\"><input name=\"msg\"><button>Display</button></form>")
		c:send("<form action=\"reboot\"><button>Reboot</button></form>")
		c:send("</body></html>")
				
	elseif (url == "/reboot") then
		c:send("HTTP/1.1 200 OK\r\n\r\n")
		c:send("<html><head><META HTTP-EQUIV=\"Refresh\" CONTENT=\"1; URL=/\"></head><body><h1>Restarting...</h1></html>")
		tmr.alarm(6, 500, 0, function() node.restart() end)
		
	else
		c:send("HTTP/1.1 404 NOT FOUND\r\n\r\n")
		c:send("<html><body><h1>404 NOT FOUND</h1></body></html>")
	end
	c:close()
	
	if body then
		local _, i, msg = body:find("msg=(.*)")
		if msg then
			lcd.print("Uptime:"..tmr.time(),msg)
		end
		local _, i, ssid, password = body:find("ssid=(.*)&password=(.*)")
		if ssid and password then
			file.open("wifi.cfg","w+")
			file.write(ssid..":"..password)
			file.close()
		end
	end		
end

print("ESP8266 listenning on port 80")
sv:listen(80,function(c)
	c:on("receive", function(c, payload)
		local e = payload:find("\r\n", 1, true)
		if not e then return nil end
		
		local line = payload:sub(1, e - 1)
		local _, i, method, url = line:find("^([A-Z]+) (.-) HTTP/1.1$")
		print("url:"..url)
					
		local body = nil
		local body_start = payload:find("\r\n\r\n", 1, true)
		if body_start then		
			body = payload:sub(body_start, #payload)		
		end		
		
		sendHtml(c,url,body)				
	end)
end)
