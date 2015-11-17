--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local assert = require('halimede.assert')
local exception = require('halimede.exception')
local Path = require('halimede.io.paths.Path')


assert.globalTableHasChieldFieldOfTypeFunction('io', 'open')
function module.openTextModeForWriting(filePath, fileDescription)
	assert.parameterTypeIsInstanceOf(filePath, Path)
	assert.parameterTypeIsString(fileDescription)
	
	filePath:assertIsFilePath()
	
	local fileHandle, errorMessage = io.open(filePath:formatPath(false), 'w')
	if fileHandle == nil then
		exception.throw("Could not open %s '%s' for text-mode writing because of error '%s'", fileDescription, filePath, errorMessage)
	end
	return fileHandle
end
local openTextModeForWriting = module.openTextModeForWriting

function module.toFileAllContentsInTextMode(filePath, fileDescription, contents)
	assert.parameterTypeIsInstanceOf(filePath, Path)
	assert.parameterTypeIsString(fileDescription)
	assert.parameterTypeIsString(contents)
	
	filePath:assertIsFilePath()
	
	local fileHandle = openTextModeForWriting(filePath, fileDescription)
	-- No errors from Lua when write or close fail...
	fileHandle:setvbuf('full', 4096)
	fileHandle:write(contents)
	fileHandle:close()
end
local toFileAllContentsInTextMode = module.toFileAllContentsInTextMode
