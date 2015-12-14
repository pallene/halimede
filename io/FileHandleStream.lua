--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local Path = halimede.io.paths.Path


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

local ioTypeFunction
if type.hasPackageChildFieldOfTypeFunctionOrCall('io', 'type') then
	ioTypeFunction = io.type
else
	ioTypeFunction = function(obj)
		return 'file'
	end
end
function module:initialize(fileHandle, description)
	assert.parameterTypeIsString('description', description)

	self.description = description
	
	if fileHandle == nil then
		self.fileHandle = nil
	else
		assert.parameterTypeIsTableOrUserdata('fileHandle', fileHandle)
		local fileHandleState = ioTypeFunction(fileHandle)
		if fileHandleState == nil then
			exception.throw('fileHandle is not a valid fileHandle')
		elseif fileHandleState == 'file' then
			self.fileHandle = fileHandle
			self.isOpen = true
		elseif fileHandleState == 'closed file' then
			self.fileHandle = nil
			self.isOpen = false
		else
			exception.throw("fileHandle state '%s' is not known", fileHandleState)
		end
	end
end

assert.globalTypeIsFunctionOrCall('pairs')
local function createFileHandleStreamsForStandardFileDescriptors()
	local mappings = {
		StandardIn = 'stdin',
		StandardOut = 'stdout',
		StandardError = 'stderr'
	}
	for to, from in pairs(mappings) do
		local fileHandleStream
		if type.hasPackageChildFieldOfTypeTableOrUserdata('io', from) then
			fileHandleStream = FileHandleStream:new(io[from], to)
		else
			fileHandleStream = FileHandleStream:new(nil, to .. ' (Unavailable)')
		end
		module.static[to] = fileHandleStream
	end
end
createFileHandleStreamsForStandardFileDescriptors()

function module:__tostring()
	return ('%s(%s)'):format(self.class.name, self.description)
end

function module:readByte()
	local byte = self.fileHandle:read(1)
	if byte == nil then
		self:close()
		return false
	end
	return byte
end

function module:readAllRemainingContentsAndClose()
	local contents = self.fileHandle:read('*a')
	self:close()
	if contents == nil then
		exception.throw('Can not read from fileHandle')
	end
	return contents
end

function module:write(contents)
	assert.parameterTypeIsString('contents', contents)
	
	self.fileHandle:write(contents)
end

function module:writeIfOpen(contents)
	if self.isOpen then
		self:write(contents)
	end
end

function module:writeAllContentsAndClose(contents)
	self.fileHandle:setvbuf('full', 4096)
	self:write(contents)
	self:close()
end

function module:close()
	if not self.isOpen then
		exception.throw('Already closed')
	end
	
	self.fileHandle:close()
	self.fileHandle = nil
	self.isOpen = false
end
