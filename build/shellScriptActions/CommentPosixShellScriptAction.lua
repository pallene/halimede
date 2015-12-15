--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = halimede.io.paths.Path
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('CommentPosixShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

function module:execute(shellScript, buildEnvironment, comment)
	assert.parameterTypeIsString('comment', comment)
	
	local safeComment = comment:gsub('\0', ''):gsub('\n', '\n# ')
	
	shellScript:appendLinesToScript('\n# ' .. safeComment)
end
