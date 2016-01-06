--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local AbstractWriteConfigHShellScriptAction = halimede.build.shellScriptActions.AbstractWriteConfigHShellScriptAction
local CommentPosixShellScriptAction = halimede.build.shellScriptActions.CommentPosixShellScriptAction


halimede.moduleclass('WriteConfigHPosixShellScriptAction', AbstractWriteConfigHShellScriptAction)

function module:initialize()
	AbstractWriteConfigHShellScriptAction.initialize(self, CommentPosixShellScriptAction)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:_append(shellScript, quotedStringShellPath, configHDefines)
	local redirected = shellScript:redirectStandardOutput(quotedStringShellPath)
	
	local lineSets = configHDefines:toCPreprocessorTextLines('\n\n')
	
	local buffer = tabelize()
	for _, lineSet in ipairs(lineSets) do
		for _, line in ipairs(lineSet) do
			buffer:insert(line)
			buffer:insert('\n')
		end
		buffer:insert('\n')
	end
	
	shellScript:appendCommandLineToScript('printf', '%s', buffer:concat(), redirected)
end
