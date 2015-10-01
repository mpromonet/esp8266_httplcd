local moduleName = ... 
local M = {}
_G[moduleName] = M 

-- Constant device address.
local MCP23008_ADDRESS = 0x20

-- Registers' address as defined in the MCP23008's datashseet
local MCP23008_IODIR = 0x00
local MCP23008_GPIO = 0x09

-- Default value for i2c communication
local id = 0

local function write(registerAddress, data)
    i2c.start(id)
    i2c.address(id,MCP23008_ADDRESS,i2c.TRANSMITTER) -- send MCP's address and write bit
    i2c.write(id,registerAddress)
    local c=i2c.write(id,data)
    i2c.stop(id)
    return c
end

local function read(registerAddress)
    -- Tell the MCP which register you want to read from
    i2c.start(id)
    i2c.address(id,MCP23008_ADDRESS,i2c.TRANSMITTER) -- send MCP's address and write bit
    i2c.write(id,registerAddress)
    i2c.stop(id)
    i2c.start(id)
    -- Read the data form the register
    i2c.address(id,MCP23008_ADDRESS,i2c.RECEIVER) -- send the MCP's address and read bit
    local data = 0x00
    data = i2c.read(id,1) -- we expect only one byte of data
    i2c.stop(id)

    return string.byte(data) -- i2c.read returns a string so we convert to it's int value
end

local function detect()
	i2c.start(id)
	c=i2c.address(id, MCP23008_ADDRESS ,i2c.TRANSMITTER)
	i2c.stop(id)
	return c
end  

function M.begin(address,pinSDA,pinSCL,speed)
	MCP23008_ADDRESS = bit.bor(MCP23008_ADDRESS,address)
	i2c.setup(id,pinSDA,pinSCL,speed)
	return detect()
end

function M.writeGPIO(dataByte)
    return write(MCP23008_GPIO,dataByte)
end

function M.readGPIO()
    return read(MCP23008_GPIO)
end

function M.writeIODIR(dataByte)
    return write(MCP23008_IODIR,dataByte)
end

function M.readIODIR()
    return read(MCP23008_IODIR)
end

return M
