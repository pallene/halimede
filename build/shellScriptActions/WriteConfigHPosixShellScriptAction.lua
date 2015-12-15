--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractWriteConfigHShellScriptAction = halimede.build.shellScriptActions.AbstractWriteConfigHShellScriptAction
local CommentPosixShellScriptAction = halimede.build.shellScriptActions.CommentPosixShellScriptAction


moduleclass('WriteConfigHPosixShellScriptAction', AbstractWriteConfigHShellScriptAction)

function module:initialize()
	AbstractConfigHShellScriptAction.initialize(self, CommentPosixShellScriptAction)
end

function module:_append(shellScript, stringFilePath, configHDefines)
	local redirected = shellScript:redirectStandardOutput(stringFilePath)
	shellScript:appendCommandLineToScript('printf', '%s', configHDefines:toCPreprocessorText('\n\n'), redirected)
end
