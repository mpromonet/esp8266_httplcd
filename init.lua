-- set uart 
uart.setup(0,115200,8,1,1,1)

-- compile
print("\n")
print("heap:"..node.heap())
for k,v in pairs(file.list()) do
	if (k:find(".lua$")) then
		print("compile "..k)
		node.compile(k) 
		print("heap:"..node.heap())
	end
end

-- init lcd
require ("lcd")
lcd.begin(0x0)

-- init AP
wifi.setmode(wifi.STATIONAP)
print("ESP8266 mode is: " .. wifi.getmode())
cfg={}
cfg.ssid="esp8266"
wifi.ap.config(cfg)
print("ESP8266 AP IP now is: " .. wifi.ap.getip())

ip, netmask, gateway = wifi.ap.getip()
lcd.print(ip,"Initializing...")

-- init STA
if file.open("wifi.cfg", "r") then
	ssid=string.sub(file.read(':'),0,-2)
	passwd=file.readline()
	file.close()
    
	wifi.sta.config(ssid,passwd)
	
	sta_up = false
	tmr.alarm(1, 1000, 1, function()
		local prev_sta_up = sta_up
		if wifi.sta.getip() == nil then
			sta_up = false
		else
			sta_up = true
		end
		
		if prev_sta_up == false and sta_up == true then
			print("ESP8266 STA IP now is: " .. wifi.sta.getip())
			lcd.print(wifi.ap.getip(), wifi.sta.getip())
			
			conn=net.createConnection(net.TCP, 0)
			conn:on("receive", function(conn, payload)
				local timeinfo = string.sub(payload,string.find(payload,"Date: ")+6,string.find(payload,"Date: ")+35)
				lcd.print("Time:", timeinfo)
				conn:close()
				end)
			conn:dns('google.com',function(conn,ip)
				conn:connect(80,ip)
				conn:send("HEAD / HTTP/1.1\r\n\r\n")
			end)
		elseif prev_sta_up == true and sta_up == false then
			print("ESP8266 STA IP no more available")
			lcd.print(wifi.ap.getip(), "Initializing...")
		end
	end)
end

dofile("httpserver.lc") 
