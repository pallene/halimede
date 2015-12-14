--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception


local StringStream = moduleclass('StringStream')

function module:initialize(initialValue, append)
	assert.parameterTypeIsString('initialValue', initialValue)
	assert.parameterTypeIsBoolean('append', append)

	self.isOpen = true
	self.value = initialValue
	if append then
		self.readPosition = #initialValue
	else
		self.readPosition = 0
end

function module:__tostring()
	return ('%s(%s)'):format(self.class.name, self.value)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'sub', 'isEmpty')
function module:readByte()
	if not self.isOpen then
		exception.throw('Is closed')
	end
	
	local newReadPosition = self.readPosition + 1
	local byte = self.value:sub(newReadPosition, newReadPosition)
	
	if byte:isEmpty() then
		self:close()
		return false
	end
	self.readPosition = newReadPosition
	return byte
end

function module:readAllRemainingContentsAndClose()
	if not self.isOpen then
		exception.throw('Is closed')
	end
	
	local newReadPosition = self.readPosition + 1
	local contents = self.value:sub(newReadPosition, #self.value)
	
	if contents:isEmpty() then
		self:close()
		return false
	end
	self.readPosition = newReadPosition
	return contents
end

function module:write(contents)
	assert.parameterTypeIsString('contents', contents)
	
	if not self.isOpen then
		exception.throw('Is closed')
	end
	
	local length = #contents
	self.value = self.value .. contents
end

function module:writeIfOpen(contents)
	if self.isOpen then
		self:write(contents)
	end
end

function module:writeAllContentsAndClose(contents)
	self:write(contents)
	self:close()
end

function module:close()
	if not self.isOpen then
		exception.throw('Already closed')
	end
	
	self.isOpen = false
end
