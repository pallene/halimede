--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local Path = halimede.io.paths.Path
local openBinaryFileForReading = halimede.io.FileHandleStream.openBinaryFileForReading
local execute = halimede.luacode.execute


assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gsub')
local function removeInitialShaBang(fileContents)
	return fileContents:gsub('^#![^\n]*\n', '')
end

local function executeFromFile(fileDescription, luaCodeFilePath, environment)
	assert.parameterTypeIsString('fileDescription', fileDescription)
	assert.parameterTypeIsInstanceOf('luaCodeFilePath', luaCodeFilePath, Path)
	assert.parameterTypeIsTable('environment', environment)

	luaCodeFilePath:assertIsFilePath('luaCodeFilePath')

	local luaCodeStringWithAnyLeadingShaBang = openBinaryFileForReading(luaCodeFilePath, fileDescription):readAllRemainingContentsAndClose()
	local luaCodeString = removeInitialShaBang(luaCodeStringWithAnyLeadingShaBang)

	return execute(luaCodeString, fileDescription, luaCodeFilePath:toString(true), environment)
end

halimede.modulefunction(executeFromFile)
