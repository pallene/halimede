--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local executeSilentlyExpectingSuccess = require('halimede.io.execute').executeSilentlyExpectingSuccess
local exception = require('halimede.exception')
local shellLanguage = require('halimede.io.ShellLanguage').Windows


local function execute(...)
	executeSilentlyExpectingSuccess(shellLanguage, ...)
end

local function notImplemented(...)
	execption.throw('')
end

-- Problems with Windows mkdir: https://stackoverflow.com/questions/905226/mkdir-p-linux-windows#905239
-- Command extensions and the fact that 'mkdir' can be GNU, so one should use 'md'
-- TODO: Overcome command extensions problems
function module.mkdir(mode, ...)
	assert.parameterTypeIsString(mode)
	
	local path = halimede.concatenateToPath(...)
	
	execute('MD', path)
end

-- Lua has os.remove(), which is semantically the same as rmdir, but since we can't iterate the directory contents, how can we delete?
-- Not really equivalent to rm -rf; doesn't delete files. See https://stackoverflow.com/questions/97875/rm-rf-equivalent-for-windows
function module.removeRecursivelyAndForce(...)
	local path = halimede.concatenateToPath(...)
	
	execute('RD', '/S', '/Q', path)
end
