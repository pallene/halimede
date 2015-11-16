--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = moduleclass('Path')

local halimede = require('halimede')
local assert = halimede.assert
local exception = require('halimede.exception')
local PathStyle = requireSibling('PathStyle')
local PathRelativity = requireSibling('PathRelativity')


Path.static.relativeFolderPath = function(pathStyle, ...)
	assert.parameterTypeIsInstanceOf(pathStyle, PathStyle)
	local relativeFolderPath = Path:new(pathStyle, PathRelativity.Relative, nil, {...}, false, nil)
end

Path.static.relativeFilePath = function(pathStyle, ...)
	assert.parameterTypeIsInstanceOf(pathStyle, PathStyle)
	return Path:new(pathStyle, PathRelativity.Relative, nil, {...}, true, nil)
end

local class = require('halimede.middleclass')
local Object = class.Object
local tabelize = require('halimede.table.tabelize').tabelize
local exception = require('halimede.exception')

-- In Windows, alternateStreamName can be empty, and it can also be things like ':$DATA' (so with the separator, it is ::$DATA)
function module:initialize(pathStyle, pathRelativity, device, pathElements, isFile, alternateStreamName)
	assert.parameterTypeIsInstanceOf(pathStyle, PathStyle)
	assert.parameterTypeIsInstanceOf(pathRelativity, PathRelativity)
	assert.parameterTypeIsStringOrNil(device)
	assert.parameterTypeIsTable(pathElements)
	assert.parameterTypeIsBoolean(isFile)
	assert.parameterTypeIsStringOrNil(alternateStreamName)
	
	local length = #pathElements
	
	if isFile then
		if length == 0 then
			exception.throw("There must be at least one path element for a file")
		end
	end
	
	if self.pathRelativity.doesNotHaveARoot then
		if length == 0 then
			exception.throw("There must be at least one path element for a relative path")
		end
	end

	if alternateStreamName ~= nil then
		if pathStyle.doesNotSupportAlternateStreams then
			exception.throw("Alternate stream names such as '%s' are not permitted for the PathStyle '%s'", alternateStreamName, pathStyle.name)
		end
	end
	
	pathRelativity:guardDeviceIsPermitted(pathStyle, device)
	pathStyle:guardPathElements(pathElements)
	
	self.pathStyle = pathStyle
	self.pathRelativity = pathRelativity
	self.device = device
	self.pathElements = pathElements
	self.isFile = isFile
	self.alternateStreamName = alternateStreamName
	
	self.isDirectory = not isFile
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'format')
function module:__tostring()
	return ('Path(%s)'):format(self:formatPath(false))
end

function module:formatPath(specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsBoolean(specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	local pathElementsCopy
	if self.alternateStreamName ~= nil then
		pathElementsCopy = shallowCopy(self.pathElements)
		local lastIndex = #pathElementsCopy
		pathElementsCopy[lastIndex] = self.pathStyle:appendAlternateStreamName(pathElements[lastIndex], alternateStreamName)
	else
		pathElementsCopy = self.pathElements
	end
	
	return self.pathRelativity:formatPath(self.pathStyle, pathElementsCopy, self.isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, self.device)
end

assert.globalTypeIsFunction('ipairs')
function module:appendFolders(...)
	if self.isFile then
		exception.throw("This is a file path")
	end
	
	local pathElementsCopy = tabelize(shallowCopy(self.pathElements))
	for _, childPathElement in ipairs({...}) do
		assert.parameterTypeIsString(childPathElement)
		
		pathElementsCopy:insert(childPathElement)
	end
	
	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, false, self.alternateStreamName)
end

function module:finalPathElementName()
	local length = #self.pathElements
	if length == 0 then
		return ''
	end
	return self.pathElements[length]
end

function module:parentPath(alternateStreamName)
	assert.parameterTypeIsStringOrNil(alternateStreamName)
	
	local length = #self.pathElements
	
	if self.pathRelativity.doesNotHaveARoot then
		if #length == 1 then
			exception.throw("Has no parent path being a one-element relative path")
		end
	else
		if #length == 0 then
			exception.throw("Is already at the root")
		end
	end
	
	local pathElementsCopy = shallowCopy(self.pathElements)
	table.remove(pathElementsCopy)
	
	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, false, alternateStreamName)
end

function module:appendFile(fileName, fileExtension, alternateStreamName)
	assert.parameterTypeIsString(fileName)
	assert.parameterTypeIsStringOrNil(fileExtension)
	assert.parameterTypeIsStringOrNil(alternateStreamName)
	
	if self.isFile then
		exception.throw("This is a file path")
	end
	
	local qualifiedFileName
	if fileExtension ~= nil then
		qualifiedFileName = self.pathStyle:appendFileExtension(fileName, fileExtension)
	else
		qualifiedFileName = fileName
	end
	
	local pathElementsCopy = shallowCopy(self.pathElements)
	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, true, alternateStreamName)
end

assert.globalTypeIsFunction('ipairs')
function module:appendRelativePath(relativePath)
	assert.parameterTypeIsInstanceOf(relativePath, Path)
	
	if not self.pathStyle.isRelative then
		exception.throw("relativePath '%s' is not isRelative", relativePath)
	end
	
	if self.isFile then
		exception.throw("This is a file path")
	end
	
	local pathElementsCopy = tabelize(shallowCopy(self.pathElements))
	for _, childPathElement in ipairs({...}) do
		assert.parameterTypeIsString(childPathElement)
		
		pathElementsCopy:insert(childPathElement)
	end
	
	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, relativePath.isFile, relativePath.alternateStreamName)
end
