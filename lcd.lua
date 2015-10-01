require ("mcp23008")

local moduleName = ... 
local M = {}
_G[moduleName] = M 

LCD_RW = 0x1
LCD_RS = 0x2
LCD_E  = 0x4

LCD_LINE_1 = 0x80 
LCD_LINE_2 = 0xC0
LCD_WIDTH = 16 

local function write_4bits(bits, mode)
	bits=bit.band(bits,0xf)
	bits=bit.lshift(bits,3)
	if (mode) then
		bits=bit.bor(bits,LCD_RS)
	end
	mcp23008.writeGPIO(bits)
	mcp23008.writeGPIO(bit.bor(bits,LCD_E))
	tmr.delay(200)
	mcp23008.writeGPIO(bits)
end
  
local function write_byte(bits, mode, postdelay, middelay)
	write_4bits(bit.rshift(bits,4),mode)  
	if (middelay ~= nil) then
		tmr.delay(middelay)
	end
	write_4bits(bit.band(bits,0xf),mode)
	if (postdelay ~= nil) then
		tmr.delay(postdelay)
	end	
end

local function write_string(line,message)
	print("lcd:"..message)
	write_byte(line,false)	
	for i = 1, #message do
		write_byte(string.byte(message, i, i),true)
	end
	for i = #message,LCD_WIDTH do
		write_byte(0x20,true)
	end
end


function M.begin(address)
	gpio0 = 3
	gpio2 = 4

	-- Setup MCP23008
	if (mcp23008.begin(address,gpio0,gpio2,i2c.SLOW)==false) then
		print("Device not found")
	else
		-- configure MCP23008
		mcp23008.writeIODIR(0x00) -- make all GPIO pins as outputs

		-- setup 4bits mode
		write_byte(0x33,false,200,10000)
		write_byte(0x32,false,200)
		
		-- initialization
		write_byte(0x28,false,200)
		write_byte(0x08,false,200)	
		write_byte(0x01,false,100000)
		write_byte(0x06,false,200)	
		write_byte(0x0c,false,200)	
	end
end


function M.print(line1, line2)
	write_string(LCD_LINE_1, line1)
	write_string(LCD_LINE_2, line2)
end

return M
