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


function module:initialize(pathSeparator, folderSeparator, deviceSeparator, currentDirectory, parentDirectory, fileExtensionSeparator, alternateStreamSeparator, hasDevices)
	self.pathSeparator = pathSeparator
	self.folderSeparator = folderSeparator
	self.deviceSeparator = deviceSeparator
	self.currentDirectory =
end

function module:appendFileExtension(fileName, fileExtension)
	return fileName .. self.fileExtensionSeparator .. fileExtension
end

-- Cmd and OpenVms only
function module:appendAlternativeStreamName(fileNameIncludingAnyExtension, alternateStreamName)
	if self.alternativeStreamSeparator == nil then
		exception.throw('Alternative stream names are not supported')
	end
	return fileNameIncludingAnyExtension .. self.alternativeStreamSeparator .. alternateStreamName
end

-- Specify '' on Posix and Symbian; omit the trailing '/' on Windows from the device
function module:formatPathAbsoluteToKnownDevice(device, pathStringsTable, isFile)
	assert.parameterTypeIsTable(pathStringsTable)
	
	return device .. self.deviceSeparator .. table.concat(pathStringsTable, self.folderSeparator)
end

-- Windows only; on Posix, effectively an absolute Path; best choice most of the time
function module:formatPathAbsoluteForCurrentDevice(pathStringsTable, isFile)
	assert.parameterTypeIsTable(pathStringsTable)
	
	return self.folderSeparator .. table.concat(pathStringsTable, self.folderSeparator)
end

function module:formatPathRelativeToCurrentDirectory(pathStringsTable, isFile)
	assert.parameterTypeIsTable(pathStringsTable)
	
	local copy = shallowCopy(pathStringsTable)
	table.insert(copy, 1, self.currentDirectory)
	return self:formatPathRelativeToAnything(pathStringsTable, isFile)
end

function module:formatPathRelativeToAnything(pathStringsTable, isFile)
	assert.parameterTypeIsTable(pathStringsTable)
	
	return table.concat(pathStringsTable, self.folderSeparator)
end

-- https://www.mpp.mpg.de/~huber/vmsdoc/VMS-UNIX_CMD-EQUIVALENTS.HTML

PathStyle.static.Posix = PathStyle:new(':', '/', '/', '.', '..', '.', nil, false)
PathStyle.static.Cmd = PathStyle:new(';', '\\', '\\', '.', '..', '.', ':', true)  -- Note that Windows allows '/' as a directory separator, too, except when using UNC paths
PathStyle.static.Cmd.formatPathRelativeToDevicesCurrentWorkingDirectory = function(device, pathStringsTable, isFile)  -- Windows, maybe OpenVms, eg C:..\file.txt
	assert.parameterTypeIsTable(pathStringsTable)
	
	return device .. self:formatPathRelativeToAnything(pathStringsTable, isFile)
end

-- Deadish
PathStyle.static.OpenVms = PathStyle.new(nil, '.', ':', '', '-', '.', ';', true)

PathStyle.static.OpenVms.formatPathAbsoluteToKnownDevice = function(self, device, pathStringsTable, isFile)
	assert.parameterTypeIsTable(pathStringsTable)
	
	return device .. self.deviceSeparator .. self:formatPathRelativeToAnything(pathStringsTable, isFile)
end

PathStyle.static.OpenVms.formatPathRelativeToAnything = function(self, pathStringsTable, isFile)
	assert.parameterTypeIsTable(pathStringsTable)
	
	if isFile then
		local folderPaths = tabelize(shallowCopy(pathStringsTable))
		local file = folderPaths:remove()
		return '[' .. folderPaths:concat(self.folderSeparator) .. ']' .. file
	else
		return '[' .. table.concate(pathStringsTable, self.folderSeparator) .. ']'
	end
	
end

PathStyle.static.Symbian = PathStyle:new(':', '\\', '\\', nil, nil, '.', nil, false)
PathStyle.static.RiscOs = PathStyle:new(nil, '.', ':', '.', '@', '^', '/', nil, true)
