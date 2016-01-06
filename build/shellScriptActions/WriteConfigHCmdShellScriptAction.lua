--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractWriteConfigHShellScriptAction = halimede.build.shellScriptActions.AbstractWriteConfigHShellScriptAction
local CommentCmdShellScriptAction = halimede.build.shellScriptActions.CommentCmdShellScriptAction


halimede.moduleclass('WriteConfigHCmdShellScriptAction', AbstractWriteConfigHShellScriptAction)

function module:initialize()
	AbstractWriteConfigHShellScriptAction.initialize(self, CommentCmdShellScriptAction)
end

-- https://stackoverflow.com/questions/1015163/heredoc-for-windows-batch
-- https://stackoverflow.com/questions/7105433/windows-batch-echo-without-new-line
assert.globalTypeIsFunctionOrCall('ipairs')
function module:_append(shellScript, quotedStringShellPath, configHDefines)
	local lineSets = configHDefines:toCPreprocessorTextLines('\r\n')
	
	local isFirstLine = true
	for _, lineSet in ipairs(lineSets) do
		for _, line in ipairs(lineSet) do
			local redirectionOperator
			if isFirstLine then
				redirectionOperator = '>'
				isFirstLine = false
			else
				redirectionOperator = '>>'
			end

			shellScript:appendLinesToScript('ECHO ' .. shellScript:toQuotedShellArgument(line) .. ' ' .. redirectionOperator .. quotedStringShellPath)
		end	
	end
end
