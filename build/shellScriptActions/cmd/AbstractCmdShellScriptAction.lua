--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractShellScriptAction = require('halimede.build.shellScriptActions.AbstractShellScriptAction')
moduleclass('AbstractCmdShellScriptAction', AbstractShellScriptAction)


function module:initialize(shellScript)
	AbstractShellScriptAction.initialize(self, shellScript)
end

function module:appendCommandWithErrorCheck(...)
	self:_appendCommandLineToScript(...)
	self:_appendLinesToScript('IF %ERRORLEVEL% NEQ 0 EXIT %ERRORLEVEL%')
end
