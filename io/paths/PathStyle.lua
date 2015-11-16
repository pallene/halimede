--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


-- https://en.wikipedia.org/wiki/Path_%28computing%29

local PathStyle = moduleclass('PathStyle')

local halimede = require('halimede')
local assert = halimede.assert
local shallowCopy = require('halimede.table.shallowCopy').shallowCopy
local exception = require('halimede.exception')


assert.globalTypeIsFunction('pairs', 'ipairs')
function module:initialize(name, pathSeparator, folderSeparator, deviceSeparator, currentDirectory, parentDirectory, fileExtensionSeparator, alternateStreamSeparator, hasDevices, additionalCharactersNotAllowedInPathElements, ...)
	assert.parameterTypeIsString(name)
	assert.parameterTypeIsStringOrNil(pathSeparator)
	assert.parameterTypeIsString(folderSeparator)
	assert.parameterTypeIsString(deviceSeparator)
	assert.parameterTypeIsStringOrNil(currentDirectory)
	assert.parameterTypeIsStringOrNil(parentDirectory)
	assert.parameterTypeIsString(fileExtensionSeparator)
	assert.parameterTypeIsStringOrNil(alternateStreamSeparator)
	assert.parameterTypeIsBoolean(hasDevices)
	assert.parameterTypeIsTable(additionalCharactersNotAllowedInPathElements)
	
	self.name = name
	self.pathSeparator = pathSeparator
	self.folderSeparator = folderSeparator
	self.deviceSeparator = deviceSeparator
	self.currentDirectory = currentDirectory
	self.parentDirectory = parentDirectory
	self.fileExtensionSeparator = fileExtensionSeparator
	self.alternateStreamSeparator = alternateStreamSeparator
	self.hasDevices = hasDevices
	
	local charactersNotAllowedInPathElements = {}
	charactersNotAllowedInPathElements['\0'] = true
	charactersNotAllowedInPathElements[folderSeparator] = true
	for _, additionalCharacterNotAllowedInPathElements in ipairs(additionalCharactersNotAllowedInPathElements) do
		charactersNotAllowedInPathElements[additionalCharacterNotAllowedInPathElements] = true
	end
	self.charactersNotAllowedInPathElements = charactersNotAllowedInPathElements
	
	local reservedPathElements = {}
	reservedPathElements[''] = true
	for reservedFolderAndFileName, _ in pairs(charactersNotAllowedInPathElements) do
		reservedPathElements[reservedFolderAndFileName] = true
	end
	for _, reservedFolderAndFileName in ipairs({...}) do
		reservedPathElements[reservedFolderAndFileName] = true
	end
	self.reservedPathElements = reservedPathElements
	
	self.doesNotSupportAlternateStreams = alternateStreamSeparator == nil
	PathStyle.static[name] = self
end

assert.globalTypeIsFunction('ipairs')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
function module:guardPathElements(pathElements)
	assert.parameterTypeIsTable(pathElements)
	
	for index, pathElement in ipairs(pathElements) do
		assert.parameterTypeIsString(pathElement)
		
		if self:isReservedPathElement(pathElement) then
			exception.throw("PathElement at index '%s' is a reserved folder or file name '%s'", index, pathElement)
		end
	end
end

assert.globalTypeIsFunction('ipairs')
assert.globalTableHasChieldFieldOfTypeFunction('string', 'match')
function module:isReservedPathElement(pathElement)
	assert.parameterTypeIsString(pathElement)
		
	if self.reservedPathElements[pathElement] then
		return true
	end
	
	for _, characterNotAllowedInPathElements in ipairs(self.charactersNotAllowedInPathElements) do
		if pathElement:match(characterNotAllowedInPathElements) then
			return true
		end
	end
	
	return false
end

function module:isReservedFileName(pathElement)
	assert.parameterTypeIsString(pathElement)
	
	if self:isReservedPathElement(pathElement) then
		return true
	end
	
	if pathElement == self.currentDirectory or pathElement == self.parentDirectory then
		return true
	end
	
	return false
end

function module:appendFileExtension(fileName, fileExtension)
	assert.parameterTypeIsString(fileName)
	assert.parameterTypeIsString(fileExtension)

	return fileName .. self.fileExtensionSeparator .. fileExtension
end

-- Cmd and OpenVms only
function module:appendAlternateStreamName(fileNameIncludingAnyExtension, alternateStreamName)
	assert.parameterTypeIsString(fileNameIncludingAnyExtension)
	assert.parameterTypeIsString(alternateStreamName)
	
	if self.alternateStreamSeparator == nil then
		exception.throw('Alternate stream names are not supported')
	end
	
	return fileNameIncludingAnyExtension .. self.alternateStreamSeparator .. alternateStreamName
end

-- Specify '' on Posix and Symbian; omit the trailing '/' on Windows from the device
function module:formatPathAbsoluteIncludingDeviceName(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)
	assert.parameterTypeIsTable(pathElements)
	assert.parameterTypeIsBoolean(isFile)
	assert.parameterTypeIsBoolean(specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsString(device)
	
	return device .. self.deviceSeparator .. self:formatPathRelative(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
end

-- Windows only; on Posix, effectively an absolute Path; best choice most of the time
function module:formatPathRelativeToCurrentDeviceAndAbsoluteOnPosix(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsTable(pathElements)
	assert.parameterTypeIsBoolean(isFile)
	assert.parameterTypeIsBoolean(specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	return self.folderSeparator .. table.concat(pathElements, self.folderSeparator)
end

-- Windows only
function module:formatPathRelativeToDeviceCurrentDirectoryOnCmd(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)
	assert.parameterTypeIsTable(pathElements)
	assert.parameterTypeIsBoolean(isFile)
	assert.parameterTypeIsBoolean(specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsString(device)
	
	exception.throw("This PathStyle '%s' does not support device relative paths on a device such as '%s'", self.name, device)
end

-- POSIX relative path, Windows relative path
-- use specifyCurrentDirectoryExplicitlyIfAppropriate for distinguishing executables in the current working directory from those in the PATH on POSIX
-- use specifyCurrentDirectoryExplicitlyIfAppropriate on Windows to avoid problems with file streams on one-character file names being mistaken for device names...
function module:formatPathRelative(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsTable(pathElements)
	assert.parameterTypeIsBoolean(isFile)
	assert.parameterTypeIsBoolean(specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	local pathElementsToUse
	if specifyCurrentDirectoryExplicitlyIfAppropriate then
		pathElementsToUse = self:prependCurrentDirectory(pathElements)
	else
		pathElementsToUse = pathElements
	end
	
	return self:_formatPathRelative(pathElementsToUse, isFile)
end

function module:_formatPathRelative(pathElements, isFile)
	return table.concat(pathElements, self.folderSeparator)
end

function module:prependCurrentDirectory(pathElements)
	assert.parameterTypeIsTable(pathElements)
	
	local copy = shallowCopy(pathElements)
	table.insert(copy, 1, self.currentDirectory)
	return copy
end

PathStyle:new('Posix', ':', '/', nil, '.', '..', '.', nil, false, {})

-- https://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx
-- Strictly speaking, \1 to \31 are valid in the alternate file stream portion of a path.
local Cmd = PathStyle:new('Cmd', ';', '\\', '\\', '.', '..', '.', ':', true, {'<', '>', ':', '"', '/', '\\', '|', '?', '*', '\1', '\2', '\3', '\4', '\5', '\6', '\7', '\8', '\9', '\10', '\11', '\12', '\13', '\14', '\15', '\16', '\17', '\18', '\19', '\20', '\21', '\22', '\23', '\24', '\25', '\26', '\27', '\28', '\29', '\30', '\31'}, 'CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9')  -- Note that Windows allows '/' as a directory separator, too, except when using UNC paths; . and .. are valid as file names when using \\?\ paths...

Cmd.formatPathRelativeToDeviceCurrentDirectoryOnCmd = function(self, pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)  -- Windows, maybe OpenVms, eg C:..\file.txt
	assert.parameterTypeIsTable(pathElements)
	assert.parameterTypeIsBoolean(isFile)
	assert.parameterTypeIsBoolean(specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsString(device)
	
	return device .. self:formatPathRelative(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
end


local OpenVms = PathStyle.new('OpenVms', nil, '.', ':', '', '-', '.', ';', true, {})

OpenVms._formatPathRelative = function(self, pathElements, isFile)
	if isFile then
		local folderPaths = tabelize(shallowCopy(pathElements))
		local file = folderPaths:remove()
		return '[' .. folderPaths:concat(self.folderSeparator) .. ']' .. file
	else
		return '[' .. table.concat(pathElements, self.folderSeparator) .. ']'
	end
	
end


PathStyle:new('Symbian', ':', '\\', '\\', nil, nil, '.', nil, false, {})


PathStyle:new('RiscOs', nil, '.', ':', '.', '@', '^', '/', nil, true, {})
