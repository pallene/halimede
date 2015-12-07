--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception


local FileHandleStream = moduleclass('FileHandleStream')

-- other things returning (read) file handles are io.open(file) and io.tmpfile()
local validModes = {
	'r',
	'w',
	'a',
	'r+',
	'w+',
	'a+',
	'rb',
	'wb',
	'ab',
	'r+b',
	'w+b',
	'a+b'
}
local openFunction
if type.hasPackageChildFieldOfTypeFunctionOrCall('io', 'open') then
	openFunction = io.open
else
	openFunction = function(filename, mode)
		assert.parameterTypeIsString('filename', filename)
		assert.parameterTypeIsStringOrNil('mode', mode)
		
		if mode ~= nil then
			if validModes[mode] == nil then
				return nil, "mode '" .. mode .. "' is not valid"
			end
		end
		
		return nil, 'io.open is not available'
	end
end

local function openFile(filePath, fileDescription, mode, modeDescription)
	assert.parameterTypeIsInstanceOf('filePath', filePath, Path)
	assert.parameterTypeIsString('fileDescription', fileDescription)
	
	filePath:assertIsFilePath('filePath')
	
	local filePathString = filePath:toString(false)
	
	local fileHandle, errorMessage = openFunction(filePathString, mode)
	if fileHandle == nil then
		exception.throw("Could not open %s '%s' in mode %s for %s because of error '%s'", fileDescription, filePath, mode, modeDescription, errorMessage)
	end
	return FileHandleStream:new(fileHandle, filePathString .. '(' .. modeDescription .. ')')
end

module.static.openTextFileForReading = function(filePath, fileDescription)
	return openFile(filePath, fileDescription, 'r', 'text-mode reading')
end

module.static.openBinaryFileForReading = function(filePath, fileDescription)
	return openFile(filePath, fileDescription, 'rb', 'binary-mode reading')
end

module.static.openTextFileForWriting = function(filePath, fileDescription)
	return openFile(filePath, fileDescription, 'w', 'text-mode writing')
end

module.static.openBinaryFileForWriting = function(filePath, fileDescription)
	return openFile(filePath, fileDescription, 'wb', 'binary-mode writing')
end

local tmpfileFunction
if type.hasPackageChildFieldOfTypeFunctionOrCall('io', 'tmpfile') then
	tmpfileFunction = io.tmpfile
else
	tmpfileFunction = function()
		return nil, 'io.tmpfile does not exist'
	end
end
module.static.openTemporaryFileForUpdate = function()
	local fileHandle, errorMessage = tmpfileFunction()
	if fileHandle == nil then
		local usefulErrorMessage
		if errorMessage == nil then
			usefulErrorMessage = '(not known)'
		else
			usefulErrorMessage = errorMessage
		end
		exception.throw("Could not open a temporary file handle in update mode because of error '%s'", usefulErrorMessage)
	end
	return FileHandleStream:new(fileHandle, 'temporary file handle (a+b)')
end

function module:initialize(fileHandle, description)
	assert.parameterTypeIsTableOrUserdata(fileHandle)
	assert.parameterTypeIsString(description)
	
	self.fileHandle = fileHandle
	self.description = description
end

function module:__tostring()
	return ('%s(%s)'):format(self.class.name, self.description)
end

function module:readAllContentsAndClose()
	local contents = self.fileHandle:read('*a')
	self:close()
	if contents == nil then
		exception.throw('Can not read from fileHandle')
	end
	return contents
end

function module.writeAllContentsAndClose(contents)
	assert.parameterTypeIsString('contents', contents)
	
	self.fileHandle:setvbuf('full', 4096)
	self.fileHandle:write(contents)
	self:close()
end

function module:close()
	if self.fileHandle == nil then
		exception.throw('Already closed')
	end
	
	self.fileHandle:close()
	self.fileHandle = nil
end
