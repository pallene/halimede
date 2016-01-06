--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local isPositiveInteger = halimede.type.isPositiveInteger
local tabelize = halimede.table.tabelize
local openBinaryFileForReading = halimede.io.FileHandleStream.openBinaryFileForReading
local m4Assert = require.sibling.m4Assert
local isVoid = m4Assert.isVoid
local isMissingOrVoid = m4Assert.isMissingOrVoid


halimede.moduleclass('DiversionBuffers')

function module:initialize()
	self.buffers = {}

	-- Buffer Zero is always active (it's standard out)
	-- We're allowed unlimited buffers; if a buffer doesn't exist, it comes into being
	self.activeBuffer = self:retrieveBuffer(0)
	self.isDiscarding = false
end

function module:write(contents)
	assert.parameterTypeIsString(contents)

	if self.isDiscarding then
		return
	end
	self.activeBuffer:append(contents)
end

-- builtin
assert.globalTypeIsFunctionOrCall('tostring')
function module:divnum()
	return tostring(self.activeBuffer.number)
end

-- builtin
assert.globalTypeIsFunctionOrCall('tonumber')
function module:divert(number)
	m4Assert.parameterTypeIsMissingOrIsVoidOrIsString('number', number)

	local actualNumber
	if isMissingOrVoid(number) then
		actualNumber = 0
	else
		actualNumber = tonumber(number)
	end

	if actualNumber < 0 then
		assert:parameterTypeIsPositiveInteger('number', -actualNumber)

		self.isDiscarding = true
		return
	else
		assert:parameterTypeIsPositiveInteger('number', actualNumber)
	end

	self.isDiscarding = false
	self.activeBuffer = self:retrieveBuffer(actualNumber)
end

-- builtin
assert.globalTypeIsFunctionOrCall('pairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
function module:undivert(...)
	local numbers = {...}
	if #numbers == 0 then
		self:undivertAll()
		self.activeBuffer = self:retrieveBuffer(0)
	end

	for _, number in pairs(numbers) do
		m4Assert.parameterTypeIsMissingOrIsVoidOrIsString('number', number)

		local actualNumber
		if not isVoid(number) then
			if number:isEmpty() then
				actualNumber = 0
			else
				actualNumber = tonumber(number)
			end
			if isPositiveInteger(actualNumber) then
				if actualNumber ~= 0 and actualNumber ~= self.activeBuffer.number then
					self.activeBuffer:append(self:retrieveBuffer(actualNumber):flush())
				end
			else
				-- Open file
				-- TODO: Pay attention to INCLUDE PATH
				local contents = openBinaryFileForReading(number, 'm4 divert'):readAllRemainingContentsAndClose()
				self.activeBuffer:append(contents)
			end
		end
		assert:parameterTypeIsPositiveInteger('number', actualNumber)

	end
end

-- Diversions are printed AFTER any wrapped text is expanded when end of input occurs
assert.globalTypeIsFunctionOrCall('pairs')
function module:undivertAll()
	if self.isDiscarding then
		return
	end

	local allKnownBuffers = tabelize()
	for _, buffer in pairs(self.buffers) do
		allKnownBuffers:insert(buffer)
	end
	allKnownBuffers:sort()

	local standardOutBuffer = self:retrieveBuffer(0)
	for _, buffer in pairs(allKnownBuffers) do
		standardOutBuffer:append(buffer:flush())
	end
end

function module:retrieveBuffer(actualNumber)
	assert:parameterTypeIsPositiveInteger(actualNumber)

	local buffer = self.buffers[actualNumber]
	if buffer then
		return buffer
	end

	buffer = DiversionBuffer:new(actualNumber)
	self.buffers[actualNumber] = buffer
	return buffer
end
