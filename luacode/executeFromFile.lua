--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = require('halimede.exception')
local execute = require('halimede.execute').execute

function module.executeFromFile(fileDescription, luaCodeFilePath, environment)
	assert.parameterTypeIsString('fileDescription', fileDescription)
	assert.parameterTypeIsString('luaCodeFilePath', luaCodeFilePath)
	assert.parameterTypeIsTable('environment', environment)
	
	local luaCodeString = removeInitialShaBang(read.allContentsInTextModeFromFile(fileDescription, luaCodeFilePath))
	
	return execute(luaCodeString, fileDescription, luaCodePath, environment)
end

local function removeInitialShaBang(fileContents)
	assert.parameterTypeIsString('fileContents', fileContents)
	
	return fileContents:gsub('^#![^\n]*\n', '')
end
