--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local exception = require('halimede.exception')
local write = requireSibling('write')

assert.globalTableHasChieldFieldOfTypeFunction('os', 'tmpname')
function module.toTemporaryFileAllContentsInTextMode(contents, fileSuffix)
	assert.parameterTypeIsString(contents)
	
	-- fileSuffix is required when creating temporary .bat or .cmd files on Windows
	local temporaryFileToWrite = os.tmpname() .. fileSuffix
	write.writeToFileAllContentsInTextMode(temporaryFileToWrite, 'temporary file', contents)
	return temporaryFileToWrite
end
local toTemporaryFileAllContentsInTextMode = module.toTemporaryFileAllContentsInTextMode

assert.globalTableHasChieldFieldOfTypeFunction('os', 'remove')
function module.toTemporaryFileAllContentsInTextModeAndUse(contents, fileSuffix, user)
	assert.parameterTypeIsString(contents)
	assert.parameterTypeIsFunction(user)

	local temporaryFileToWrite = writeToTemporaryFileAllContentsInTextMode(contents, fileSuffix)
	local ok, result = pcall(user, temporaryFileToWrite)
	os.remove(temporaryFileToWrite)
	if not ok then
		error(result)
	end
	
	return result
end
local toTemporaryFileAllContentsInTextModeAndUse = module.toTemporaryFileAllContentsInTextModeAndUse
