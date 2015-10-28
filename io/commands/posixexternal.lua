--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local executeSilentlyExpectingSuccess = require('halimede.io.execute').executeSilentlyExpectingSuccess
local exception = require('halimede.exception')
local shellLanguage = require('halimede.io.ShellLanguage').POSIX


local function execute(...)
	executeSilentlyExpectingSuccess(shellLanguage, ...)
end

function module.mkdir(mode, ...)
	assert.parameterTypeIsString(mode)
	
	local path = halimede.concatenateToPath(...)
	execute('mkdir', '-m', mode, '-p', path)
end

function module.removeRecursivelyAndForce(...)
	
	local path = halimede.concatenateToPath(...)
	execute('rm', '-rf', path)
end
