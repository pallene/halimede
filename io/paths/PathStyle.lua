--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local shallowCopy = halimede.table.shallowCopy
local exception = halimede.exception
local windowsPathMultisplitter = halimede.string.multisplitter('\\/')
local Path = require.sibling('Path')
local PathRelativity = require.sibling('PathRelativity')


-- https://en.wikipedia.org/wiki/Path_%28computing%29
local PathStyle = moduleclass('PathStyle')

assert.globalTypeIsFunctionOrCall('pairs', 'ipairs')
function module:initialize(name, pathSeparator, folderSeparator, deviceSeparator, currentDirectory, parentDirectory, fileExtensionSeparator, alternateStreamSeparator, hasDevices, additionalCharactersNotAllowedInPathElements, ...)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsStringOrNil('pathSeparator', pathSeparator)
	assert.parameterTypeIsString('folderSeparator', folderSeparator)
	assert.parameterTypeIsStringOrNil('deviceSeparator', deviceSeparator)
	assert.parameterTypeIsStringOrNil('currentDirectory', currentDirectory)
	assert.parameterTypeIsStringOrNil('parentDirectory', parentDirectory)
	assert.parameterTypeIsString('fileExtensionSeparator', fileExtensionSeparator)
	assert.parameterTypeIsStringOrNil('alternateStreamSeparator', alternateStreamSeparator)
	assert.parameterTypeIsBoolean('hasDevices', hasDevices)
	assert.parameterTypeIsTable('additionalCharactersNotAllowedInPathElements', additionalCharactersNotAllowedInPathElements)
	
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

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
function module:parse(stringPath, isFile)
	assert.parameterTypeIsString('stringPath', stringPath)
	assert.parameterTypeIsBoolean('isFile', isFile)
	
	if stringPath:isEmpty() then
		exception.throw("The stringPath is empty")
	end
	
	return self:_parse(stringPath, isFile)
end

function module:_parse(stringPath, isFile)
	exception.throw('Abstract Method')
end

function module:relativeFolderPath(...)
	return Path:new(self, PathRelativity.Relative, nil, {...}, false, nil)
end

function module:relativeFilePath(...)
	return Path:new(self, PathRelativity.Relative, nil, {...}, true, nil)
end

assert.globalTypeIsFunctionOrCall('ipairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'len')
function module:guardPathElements(pathElements)
	assert.parameterTypeIsTable('pathElements', pathElements)
	
	for index, pathElement in ipairs(pathElements) do
		assert.parameterTypeIsString('pathElement', pathElement)
		
		if self:isReservedPathElement(pathElement) then
			exception.throw("PathElement at index '%s' is a reserved folder or file name '%s'", index, pathElement)
		end
	end
end

assert.globalTypeIsFunctionOrCall('ipairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match')
function module:isReservedPathElement(pathElement)
	assert.parameterTypeIsString('pathElement', pathElement)
		
	if self.reservedPathElements[pathElement] then
		return true
	end
	
	for _, characterNotAllowedInPathElements in ipairs(self.charactersNotAllowedInPathElements) do
		if pathElement:find(characterNotAllowedInPathElements, 1, true) ~= nil then
			return true
		end
	end
	
	return false
end

function module:isReservedFileName(pathElement)
	assert.parameterTypeIsString('pathElement', pathElement)
	
	if self:isReservedPathElement(pathElement) then
		return true
	end
	
	if pathElement == self.currentDirectory or pathElement == self.parentDirectory then
		return true
	end
	
	return false
end

function module:appendFileExtension(fileName, fileExtension)
	assert.parameterTypeIsString('fileName', fileName)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	
	if fileExtension == nil then
		return fileName
	end

	return fileName .. self.fileExtensionSeparator .. fileExtension
end

-- Cmd and OpenVms only
function module:appendAlternateStreamName(fileNameIncludingAnyExtension, alternateStreamName)
	assert.parameterTypeIsString('fileNameIncludingAnyExtension', fileNameIncludingAnyExtension)
	assert.parameterTypeIsString('alternateStreamName', alternateStreamName)
	
	if self.alternateStreamSeparator == nil then
		exception.throw('Alternate stream names are not supported')
	end
	
	return fileNameIncludingAnyExtension .. self.alternateStreamSeparator .. alternateStreamName
end

-- Specify '' on Posix and Symbian; omit the trailing '/' on Windows from the device
function module:toStringAbsoluteIncludingDeviceName(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)
	assert.parameterTypeIsTable('pathElements', pathElements)
	assert.parameterTypeIsBoolean('isFile', isFile)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsString('device', device)
	
	return device .. self.deviceSeparator .. self:toStringRelative(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
end

-- Windows only; on Posix, effectively an absolute Path; best choice most of the time
function module:toStringRelativeToCurrentDeviceAndAbsoluteOnPosix(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsTable('pathElements', pathElements)
	assert.parameterTypeIsBoolean('isFile', isFile)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	return self.folderSeparator .. table.concat(pathElements, self.folderSeparator)
end

-- Windows only
function module:toStringRelativeToDeviceCurrentDirectoryOnCmd(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)
	assert.parameterTypeIsTable('pathElements', pathElements)
	assert.parameterTypeIsBoolean('isFile', isFile)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsString('device', device)
	
	exception.throw("This PathStyle '%s' does not support device relative paths on a device such as '%s'", self.name, device)
end

-- POSIX relative path, Windows relative path
-- use specifyCurrentDirectoryExplicitlyIfAppropriate for distinguishing executables in the current working directory from those in the PATH on POSIX
-- use specifyCurrentDirectoryExplicitlyIfAppropriate on Windows to avoid problems with file streams on one-character file names being mistaken for device names...
function module:toStringRelative(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsTable('pathElements', pathElements)
	assert.parameterTypeIsBoolean('isFile', isFile)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	local pathElementsToUse
	if specifyCurrentDirectoryExplicitlyIfAppropriate then
		if pathElements[1] == self.currentDirectory or pathElements[1] == self.parentDirectory then
			pathElementsToUse = pathElements
		else
			pathElementsToUse = self:prependCurrentDirectory(pathElements)
		end
	else
		pathElementsToUse = pathElements
	end
	
	return self:_toStringRelative(pathElementsToUse, isFile)
end

function module:_toStringRelative(pathElements, isFile)
	return table.concat(pathElements, self.folderSeparator)
end

function module:prependCurrentDirectory(pathElements)
	assert.parameterTypeIsTable('pathElements', pathElements)
	
	local copy = shallowCopy(pathElements)
	table.insert(copy, 1, self.currentDirectory)
	return copy
end


local Posix = PathStyle:new('Posix', ':', '/', nil, '.', '..', '.', nil, false, {})

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'len', 'sub', 'split', 'isEmpty')
Posix._parse = function(self, stringPath, isFile)
	
	local pathElements = stringPath:split('/')
	local pathRelativity
	if stringPath:sub(1, 1) == '/' then
		table.remove(pathElements, 1)
		pathRelativity = PathRelativity.RelativeToCurrentDeviceAndAbsoluteOnPosix
	else
		pathRelativity = PathRelativity.Relative
	end
	if #pathElements == 1 and pathElements[1]:isEmpty() and not isFile then
		return Path:new(self, pathRelativity, nil, {}, isFile, nil)
	end
	return Path:new(self, pathRelativity, nil, pathElements, isFile, nil)
end


-- https://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx
-- Strictly speaking, \1 to \31 are valid in the alternate file stream portion of a path.
local Cmd = PathStyle:new('Cmd', ';', '\\', '\\', '.', '..', '.', ':', true, {'<', '>', ':', '"', '/', '\\', '|', '?', '*', '\1', '\2', '\3', '\4', '\5', '\6', '\7', '\8', '\9', '\10', '\11', '\12', '\13', '\14', '\15', '\16', '\17', '\18', '\19', '\20', '\21', '\22', '\23', '\24', '\25', '\26', '\27', '\28', '\29', '\30', '\31'}, 'CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9')  -- Note that Windows allows '/' as a directory separator, too, except when using UNC paths; . and .. are valid as file names when using \\?\ paths...

Cmd.toStringRelativeToDeviceCurrentDirectoryOnCmd = function(self, pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)  -- Windows, maybe OpenVms, eg C:..\file.txt
	assert.parameterTypeIsTable('pathElements', pathElements)
	assert.parameterTypeIsBoolean('isFile', isFile)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsString('device', device)
	
	return device .. self:toStringRelative(pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split', 'find', 'sub')
Cmd._parse = function(self, stringPath, isFile)

	local pathElements
	local pathRelativity
	local device
	
	-- UNC-style
	if stringPath:sub(1, 2) == '\\\\' then

		local uncNamespace = stringPath:sub(1, 4)
		
		if uncNamespace == '\\\\.\\' then
			-- Win32 Device Namespaces (Device selector)
			pathElements = windowsPathMultisplitter(stringPath:sub(5))
			device = '\\\\.\\' .. pathElements:remove(1)
			pathRelativity = PathRelativity.AbsoluteIncludingDeviceName
			
			-- things like \\.\NUL and \\.\COM5 won't work because we check for them in the path element
			exception.throw('Device namespaces are not supported at this time')
			
		elseif uncNamespace == '\\\\?\\' then
			-- Win32 File Namespaces (Win32API selector)
			-- . and .. no longer refer to current directory or parent directory
			-- Effectively absolute paths, so we can treat them as '\\?\<device>\'
			-- '/' is NOT VALID as a folder separator for \\?\ UNC namespaces, hence the split() not windowsPathMultisplitter()
			pathElements = stringPath:sub(5):split('\\')
			
			device = '\\\\?\\' .. pathElements:remove(1)
			
			-- Long UNC form
			if pathElements[1] == 'UNC' then
				device = device .. '\\' .. pathElements:remove(1)
			end
			
			-- Not sure if \\?\C:file.txt is valid; we're assuming it isn't for now
			pathRelativity = PathRelativity.AbsoluteIncludingDeviceName
		else
			-- Filespace selector  see https://msdn.microsoft.com/en-us/library/gg465305.aspx
			-- \\ComputerName\SharedName\Path
			pathElements = windowsPathMultisplitter(stringPath:sub(3))
			device = '\\\\' .. pathElements:remove(1)
			pathRelativity = PathRelativity.AbsoluteIncludingDeviceName
		end
	else
		pathElements = windowsPathMultisplitter(stringPath)
		device = nil
		if stringPath:sub(1, 1) == '\\' then
			pathElements:remove(1)
			pathRelativity = PathRelativity.RelativeToCurrentDeviceAndAbsoluteOnPosix
		elseif stringPath:sub(2, 1) == ':' then
			device = pathElements:remove(1)
			-- Is this C: or C:\ or C:/ ?
			local thirdCharacter = stringPath:sub(3, 1)
			if thirdCharacter == '\\' or thirdCharacter == '/' then
				pathRelativity = PathRelativity.AbsoluteIncludingDeviceName
			else
				pathRelativity = PathRelativity.RelativeToDeviceCurrentDirectoryOnCmd
			end
		else
			pathRelativity = PathRelativity.Relative
		end
	end
	
	local alternateStreamName = nil
	local lastIndex = #pathElements
	if lastIndex > 0 then
		local lastPathElement = pathElements[lastIndex]
		local firstIndex = lastPathElement:find(':')
		if firstIndex then
			pathElements[lastIndex] = lastPathElement:sub(1, firstIndex - 1)
			alternateStreamName = lastPathElement:sub(firstIndex + 1)
		end
	end

	return Path:new(self, pathRelativity, device, pathElements, isFile, alternateStreamName)
end


local OpenVms = PathStyle:new('OpenVms', nil, '.', ':', '', '-', '.', ';', true, {})

OpenVms._toStringRelative = function(self, pathElements, isFile)
	if isFile then
		local folderPaths = tabelize(shallowCopy(pathElements))
		local file = folderPaths:remove()
		return '[' .. folderPaths:concat(self.folderSeparator) .. ']' .. file
	else
		return '[' .. table.concat(pathElements, self.folderSeparator) .. ']'
	end
	
end


PathStyle:new('Symbian', ':', '\\', '\\', nil, nil, '.', nil, false, {})


PathStyle:new('RiscOs', nil,  '.',  ':',  '.', '@', '^', nil, true,  {})
