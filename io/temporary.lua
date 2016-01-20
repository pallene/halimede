--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local exception = halimede.exception
local shellLanguage = halimede.io.shellScript.ShellLanguage.default()
local FileHandleStream = halimede.io.FileHandleStream
local packageConfiguration = halimede.packageConfiguration


local tmpnameFunction
if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'tmpname') then
	tmpnameFunction = os.tmpname
else
	-- Insecure but usable temporary file function
	if type.hasPackageChildFieldOfTypeFunctionOrCall('math', 'random') and type.hasGlobalOfTypeFunctionOrCall('tostring') then

		local PosixTemporaryDefaults = {
			defaultTemporaryPath = '/tmp',
			-- Note that HOME will dump stuff in the User's home. Too bad; it's a failsafe.
			environmentVariables = { 'TMPDIR', 'HOME' }
		}

		--noinspection UnusedDef
		local WindowsTemporaryDefaults = {
			-- Almost certainly wrong
			defaultTemporaryPath = 'C:\\temp',
			-- Note that the last three variables will dump stuff in unwanted locations.
			environmentVariables = { 'TEMP', 'TMP', 'LOCALAPPDATA', 'HOMEPATH', 'USERPROFILE' }
		}

		-- Poor man's check of running on Windows; ignores OpenVMS' SYS$SCRATCH, AmigaDOS T: and Symbian
		local defaults = packageConfiguration:isProbablyWindows() and WindowsTemporaryDefaults or PosixTemporaryDefaults

		local temporaryPath = defaults.defaultTemporaryPath
		for _, environmentVariableName in ipairs(defaults.environmentVariables) do
			local environmentVariableValue = halimede.getenv(environmentVariableName)
			if environmentVariableValue ~= nil then
				temporaryPath = environmentVariableValue
				break
			end
		end

		tmpnameFunction = function()
			local temporaryFileName = 'lua-halimede-' .. tostring(math.random(0, 999999999999999))
			return shellLanguage:parsePath(temporaryPath, false):appendFile(temporaryFileName):toString(true)
		end
		-- We can also use mktemp (not POSIX!), awk, etc but we're starting to clutch at straws, and shelling out isn't a great idea
	else
		tmpnameFunction = function()
			exception.throw('os.tmpname and math.random and tostring do not exist')
		end
	end
end

assert.globalTypeIsFunctionOrCall('pcall')
local function useTemporaryFile(fileExtension, fileHandleStreamUser, opener, description)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	assert.parameterTypeIsFunctionOrCall('fileHandleStreamUser', fileHandleStreamUser)
	assert.parameterTypeIsFunctionOrCall('opener', opener)
	assert.parameterTypeIsString('description', description)

	local temporaryFileCreatedOnPosixButNotWindows = tmpnameFunction()

	local temporaryFilePath = shellLanguage:parsePath(temporaryFileCreatedOnPosixButNotWindows, true)
	local temporaryFilePathWithFileExtension = temporaryFilePath:appendFileExtension(fileExtension)

	local fileHandleStream = opener(temporaryFilePathWithFileExtension, description)
	local ok, result = pcall(fileHandleStreamUser, temporaryFilePathWithFileExtension, fileHandleStream)
	if fileHandleStream.isOpen then
		fileHandleStream:close()
	end

	if temporaryFilePathWithFileExtension ~= temporaryFilePath then
		temporaryFilePathWithFileExtension:remove()
	end
	temporaryFilePath:remove()

	if ok then
		return result
	end
	exception.throw(result)
end
module.useTemporaryFile = useTemporaryFile

local function useTemporaryTextFile(fileExtension, fileHandleStreamUser)
	return useTemporaryFile(fileExtension, fileHandleStreamUser, FileHandleStream.openTextFileForWriting, 'temporary text file (writing)')
end
module.useTemporaryTextFile = useTemporaryTextFile

function module.useTemporaryTextFileAfterWritingAllContentsAndClosing(fileExtension, contents, filePathUser)
	return useTemporaryTextFile(fileExtension, function(temporaryFilePath, fileHandleStream)

		fileHandleStream:writeAllContentsAndClose(contents)

		return filePathUser(temporaryFilePath)
	end)
end
