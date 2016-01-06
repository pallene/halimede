--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local sibling = halimede.io.paths
local type = halimede.type
local isTable = type.isTable
local isString = type.isString
local exception = halimede.exception
local tabelize = halimede.table.tabelize
local shallowCopy = halimede.table.shallowCopy
local areInstancesEqual = halimede.table.equality.areInstancesEqual
local PathStyle = sibling.PathStyle
local PathRelativity = sibling.PathRelativity
local ShellArgument = halimede.io.shellScript.ShellArgument


local Path = halimede.moduleclass('Path')

-- In Windows, alternateStreamName can be empty, and it can also be things like ':$DATA' (so with the separator, it is ::$DATA)
function module:initialize(pathStyle, pathRelativity, device, pathElements, isFile, alternateStreamName)
	assert.parameterTypeIsInstanceOf('pathStyle', pathStyle, PathStyle)
	assert.parameterTypeIsInstanceOf('pathRelativity', pathRelativity, PathRelativity)
	assert.parameterTypeIsStringOrNil('device', device)
	assert.parameterTypeIsTable('pathElements', pathElements)
	assert.parameterTypeIsBoolean('isFile', isFile)
	assert.parameterTypeIsStringOrNil('alternateStreamName', alternateStreamName)

	local length = #pathElements

	if isFile then
		if length == 0 then
			exception.throw("There must be at least one path element for a file")
		end
	end

	if pathRelativity.doesNotHaveARoot then
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
	self.isDeviceOrRoot = length < 2

	self.numberOfPathElements = #self.pathElements
end

local simpleEqualityFieldNames = {'pathStyle', 'pathRelativity', 'isFile'}
local shallowArrayFieldNames = {'pathElements'}
local potentiallyNilFieldNames = {'device', 'alternateStreamName'}
function module:__eq(right)
	return areInstancesEqual(self, right, simpleEqualityFieldNames, shallowArrayFieldNames, potentiallyNilFieldNames)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module:__tostring()
	return ('%s(%s)'):format(self.class.name, self:toString(false))
end

function module:assertIsFolderPath(parameterName)
	if self.isFile then
		exception.throw("%s '%s' is a file path", parameterName, self:__tostring())
	end
end

function module:assertIsFilePath(parameterName)
	if self.isDirectory then
		exception.throw("%s '%s' is a folder path", parameterName, self:__tostring())
	end
end

function module:assertIsEffectivelyAbsolute(parameterName)
	if not self.pathRelativity.isEffectivelyAbsolute then
		exception.throw("%s '%s' must be effectively absolute", parameterName, self:__tostring())
	end
end

function module:assertIsRelative(parameterName)
	if not self.pathRelativity.isRelative then
		exception.throw("%s '%s' must be relative", parameterName, self:__tostring())
	end
end

function module:openFile(fileHandleStreamOpenerFunction, fileDescription)
	assert.parameterTypeIsFunctionOrCall('fileHandleStreamOpenerFunction', fileHandleStreamOpenerFunction)
	assert.parameterTypeIsString('fileDescription', fileDescription)

	return fileHandleStreamOpenerFunction(self, fileDescription)
end

function module:toString(specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)

	local pathElementsCopy
	if self.alternateStreamName ~= nil then
		pathElementsCopy = shallowCopy(self.pathElements)
		local lastIndex = #pathElementsCopy
		pathElementsCopy[lastIndex] = self.pathStyle:appendAlternateStreamName(pathElements[lastIndex], alternateStreamName)
	else
		pathElementsCopy = self.pathElements
	end

	return self.pathRelativity:toString(self.pathStyle, pathElementsCopy, self.isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, self.device)
end

function module:toQuotedShellArgumentX(specifyCurrentDirectoryExplicitlyIfAppropriate, shellLanguage)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	-- including ShellLanguage here causes a circular dependency
	--assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)

	return ShellArgument:new(shellLanguage:toQuotedShellArgument(self:toString(specifyCurrentDirectoryExplicitlyIfAppropriate)))
end

function module:hasNonEmptyDevice()
	local pathRelativity = self.pathRelativity
	local hasDevice = pathRelativity.isAbsoluteIncludingDeviceName or pathRelativity.isRelativeToDeviceCurrentDirectoryOnCmd
	return self.device ~= nil and hasDevice
end

if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'remove') then
	function module:remove()
		local ok, errorMessage = os.remove(self:toString(true))
		if ok == nil then
			return false, errorMessage
		end
		return true, 'removed'
	end
else
	function module:remove()
		return false, 'os.remove() is not available'
	end
end

function module:finalPathElementNameAsString()
	local length = #self.pathElements
	if length == 0 then
		return ''
	end
	local finalPathElementNameAsString = self.pathElements[length]
	return finalPathElementNameAsString
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
function module:finalPathElementNameAsPath()
	local finalPathElementNameAsString = self:finalPathElementNameAsString()
	local pathElements
	if finalPathElementNameAsString:isEmpty() then
		pathElements = {}
	else
		pathElements = {finalPathElementNameAsString}
	end
	return Path:new(self.pathStyle, PathRelativity.Relative, self.device, pathElements, self.isFile, nil)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:appendFolders(...)
	self:assertIsFolderPath('self')

	local asTable = {...}
	if #asTable == 0 then
		return self
	end

	local pathElementsCopy = tabelize(shallowCopy(self.pathElements))
	for _, childPathElement in ipairs(asTable) do
		assert.parameterTypeIsString('childPathElement', childPathElement)

		pathElementsCopy:insert(childPathElement)
	end

	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, false, self.alternateStreamName)
end

function module:strippedOfFinalPathElement(alternateStreamName)
	assert.parameterTypeIsStringOrNil('alternateStreamName', alternateStreamName)

	local length = #self.pathElements

	if self.pathRelativity.doesNotHaveARoot then
		if length == 1 then
			return Path:new(self.pathStyle, self.pathRelativity, self.device, {self.pathStyle.currentDirectory}, false, alternateStreamName)
		end
	else
		if length == 0 then
			exception.throw("Is already at the root")
		end
	end

	local pathElementsCopy = shallowCopy(self.pathElements)
	table.remove(pathElementsCopy)

	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, false, alternateStreamName)
end

function module:appendFile(fileName, fileExtension, alternateStreamName)
	assert.parameterTypeIsString('fileName', fileName)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	assert.parameterTypeIsStringOrNil('alternateStreamName', alternateStreamName)

	self:assertIsFolderPath('self')

	local qualifiedFileName
	if fileExtension ~= nil then
		qualifiedFileName = self.pathStyle:appendFileExtension(fileName, fileExtension)
	else
		qualifiedFileName = fileName
	end

	local pathElementsCopy = shallowCopy(self.pathElements)
	table.insert(pathElementsCopy, qualifiedFileName)
	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, true, alternateStreamName)
end

function module:appendFileExtension(fileExtension, alternateStreamName)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	assert.parameterTypeIsStringOrNil('alternateStreamName', alternateStreamName)

	self:assertIsFilePath('self')

	if fileExtension == nil then
		return self
	end

	local pathElementsCopy = shallowCopy(self.pathElements)
	local length = #pathElementsCopy
	pathElementsCopy[length] = self.pathStyle:appendFileExtension(pathElementsCopy[length], fileExtension)
	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, true, alternateStreamName)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:appendRelativePath(relativePath)
	return self:_appendPathAsRelativePath(relativePath, 'relativePath', 'assertIsRelative')
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:appendAbsolutePathAsRelativePath(absolutePath)
	return self:_appendPathAsRelativePath(absolutePath, 'absolutePath', 'assertIsEffectivelyAbsolute')
end

function module:_appendPathAsRelativePath(path, parameterName, assertionName)
	assert.parameterTypeIsInstanceOf('path', path, Path)

	path[assertionName](path, parameterName)

	self:assertIsFolderPath('self')

	if self.pathStyle ~= path.pathStyle then
		exception.throw("self.pathStyle '%s' differs from path.pathStyle '%s'", self.pathStyle, path.pathStyle)
	end

	local pathElementsCopy = tabelize(shallowCopy(self.pathElements))
	for _, childPathElement in ipairs(path.pathElements) do
		assert.parameterTypeIsString('childPathElement', childPathElement)

		pathElementsCopy:insert(childPathElement)
	end

	return Path:new(self.pathStyle, self.pathRelativity, self.device, pathElementsCopy, path.isFile, path.alternateStreamName)
end

assert.globalTypeIsFunctionOrCall('ipairs', 'unpack')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
function module:filePaths(fileExtension, baseFilePaths)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	assert.parameterTypeIsTable('baseFilePaths', baseFilePaths)
	
	self:assertIsFolderPath('self')

	local filePaths = tabelize()
	for _, stringOrTable in ipairs(baseFilePaths) do
		local path
		if isTable(stringOrTable) then
			local length = #stringOrTable
			local folders = {}
			local index = 1
			while index < length do
				local pathElement = stringOrTable[index]
				assert.parameterTypeIsString('baseFilePaths', pathElement)

				folders[index] = pathElement
				index = index + 1
			end
			local fileName = stringOrTable[length]
			path = self:appendFolders(unpack(folders)):appendFile(fileName, fileExtension)
		elseif isString(stringOrTable) then
			path = self:appendFile(stringOrTable, fileExtension)
		else
			exception.throw('baseFilePaths should only contain strings or tables of string')
		end
		filePaths:insert(path)
	end
	return filePaths
end
