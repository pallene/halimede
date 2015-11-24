--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local Path = halimede.io.paths.Path')


assert.globalTableHasChieldFieldOfTypeFunction('io', 'open')
function module.openTextModeForReading(filePath, fileDescription)
	assert.parameterTypeIsInstanceOf('filePath', filePath, Path)
	assert.parameterTypeIsString('fileDescription', fileDescription)
	
	filePath:assertIsFilePath('filePath')
	
	local fileHandle, errorMessage = io.open(filePath:toString(false), 'r')
	if fileHandle == nil then
		exception.throw("Could not open %s '%s' for text-mode reading because of error '%s'", fileDescription, filePath, errorMessage)
	end
	return fileHandle
	
end
local openTextModeForReading = module.openTextModeForReading

function module.allContentsInTextModeFromFileHandleAndClose(fileHandle)
	assert.parameterTypeIsUserdata('fileHandle', fileHandle)
	
	local contents = fileHandle:read('*a')
	fileHandle:close()
	if contents == nil then
		exception.throw('Can not read from fileHandle')
	end
	return contents
end
local allContentsInTextModeFromFileHandleAndClose = module.allContentsInTextModeFromFileHandleAndClose

assert.globalTypeIsFunction('pcall')
function module.allContentsInTextModeFromFile(filePath, fileDescription)
	assert.parameterTypeIsInstanceOf('filePath', filePath, Path)
	assert.parameterTypeIsString('fileDescription', fileDescription)
	
	filePath:assertIsFilePath('filePath')
	
	local fileHandle = openTextModeForReading(filePath, fileDescription)
	local ok, contentsOrError = pcall(allContentsInTextModeFromFileHandleAndClose, fileHandle)
	if ok then
		return contentsOrError
	end
	exception.throw("Could not read %s '%s' (in text mode) because of error during read", fileDescription, filePath)
end
