--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local write = requireSibling('write')
local Path = halimede.io.paths.Path
local DefaultShellLanguage = halimede.io.shellScript.ShellLanguage.Default


assert.globalTableHasChieldFieldOfTypeFunction('os', 'tmpname')
function module.toTemporaryFileAllContentsInTextMode(contents, fileExtension)
	assert.parameterTypeIsString('contents', contents)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	
	local temporaryFileCreatedOnPosixButNotWindows = os.tmpname()
	
	local temporaryFilePath = DefaultShellLanguage:parsePath(temporaryFileCreatedOnPosixButNotWindows, true)
	local temporaryFilePathWithFileExtension = temporaryFilePath:appendFileExtension(fileExtension)
	
	write.toFileAllContentsInTextMode(temporaryFilePathWithFileExtension, 'temporary file', contents)
	return temporaryFilePathWithFileExtension, function()
		if temporaryFilePathWithFileExtension ~= temporaryFilePath then
			temporaryFilePathWithFileExtension:remove()
		end
		temporaryFilePath:remove()
	end
end
local toTemporaryFileAllContentsInTextMode = module.toTemporaryFileAllContentsInTextMode

assert.globalTypeIsFunction('pcall')
function module.toTemporaryFileAllContentsInTextModeAndUse(contents, fileExtension, user)
	assert.parameterTypeIsString('contents', contents)
	assert.parameterTypeIsStringOrNil('fileExtension', fileExtension)
	assert.parameterTypeIsFunction('user', user)

	local temporaryFilePathWithFileExtension, removeTemporaryFiles = toTemporaryFileAllContentsInTextMode(contents, fileExtension)
	local ok, result = pcall(user, temporaryFilePathWithFileExtension)
	removeTemporaryFiles()
	if not ok then
		exception.throw(result)
	end
	return result
end
local toTemporaryFileAllContentsInTextModeAndUse = module.toTemporaryFileAllContentsInTextModeAndUse
