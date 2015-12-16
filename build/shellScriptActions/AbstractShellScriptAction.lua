--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ShellScript = halimede.io.shellScript.ShellScript
local exception = halimede.exception


moduleclass('AbstractShellScriptAction')

function module:initialize()
end

function module:__call(...)
	return self:execute(...)
end

function module:execute(shellScript, builder, ...)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)
	assert.parameterTypeIsTable('builder', builder)
	
	return self:_execute(shellScript, builder, ...)
end

function module:_execute(shellScript, builder, ...)
	exception.throw('Abstract Method')
end

function module:_quoteShellPath(shellScript, path, specifyCurrentDirectoryExplicitlyIfAppropriate)
	return path:quoteArgument(shellScript.shellLanguage, specifyCurrentDirectoryExplicitlyIfAppropriate)
end
