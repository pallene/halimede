--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('AbstractShellScriptAction')

local assert = require('halimede').assert
local BufferedShellScript = require('halimede.io.shellScript.BufferedShellScript')

local exception = require('halimede.exception')


function module:initialize(shellScript)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, BufferedShellScript)
	
	self.shellScript = shellScript
end

function module:__call(self, ...)
	return self:execute(...)
end

function module:execute(...)
	exception.throw('Abstract Method')
end

function module:_quoteArgument(argument)
	return self.shellScript:quoteArgument(argument)
end

function module:_redirectStandardOutput(filePathOrFileDescriptor)
	return self.shellScript:redirectStandardOutput(fileOrFileDescriptor)
end

function module:_appendLinesToScript(...)
	self.shellScript:appendLinesToScript(...)
end

function module:_appendCommandLineToScript(...)
	self.shellScript:appendCommandLineToScript(...)
end
