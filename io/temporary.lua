--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local Path = halimede.io.paths.Path
local shellLanguage = halimede.io.shellScript.ShellLanguage.default()
local FileHandleStream = halimede.io.FileHandleStream
local packageConfiguration = halimede.packageConfiguration


local tmpnameFunction
if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'tmpname') then
	tmpnameFunction = os.tmpname
else
	-- Insecure but usable temporary file function
	if type.hasPackageChildFieldOfTypeFunctionOrCall('math', 'random') then
		
		-- Poor man's check of running on Windows; ignores OpenVMS' SYS$SCRATCH and AmigaDOS T:
		local defaultTemporaryPath
		local environmentVariables
		if packageConfiguration.folderSeparator == '/' then
			defaultTemporaryPath = '/tmp'
			environmentVariables = {'TMPDIR'}
			-- HOME is also probably writable
		else
			-- Probably wrong: https://en.wikipedia.org/wiki/Temporary_folder
			defaultTemporaryPath = 'C:\\temp'
			environmentVariables = {'TEMP', 'TMP'}
		end
		
		local temporaryPath = defaultTemporaryPath
		if type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'getenv') then
			for _, environmentVariableName in ipairs(environmentVariables) do
				local environmentVariableValue = os.getenv(environmentVariableName)
				if environmentVariableValue ~= nil then
					temporaryPath = environmentVariableValue
					break
				end
			end
		end
		
		tmpnameFunction = function()
			local temporaryFileName = math.random(0, 999999999999999)
			return shellLanguage:parsePath(temporaryPath, false):appendFile(temporaryFileName):toString(true)
		end
	-- We can also use mktemp (not POSIX!), awk, etc but we're starting to clutch at straws, and shelling out isn't a great idea
	else
		tmpnameFunction = function()
			exception.throw('os.tmpname does not exist')
		end
	end
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('os', 'tmpname')
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
	if fileHandleStream.fileHandle ~= nil then
		fileHandleStream:close(contents)
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