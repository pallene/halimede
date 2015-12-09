--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ConfigHDefines = halimede.build.defines.ConfigHDefines
local Path = halimede.io.paths.Path
local AbstractShellScriptAction = halimede.build.shellScriptActions.AbstractShellScriptAction


moduleclass('WriteConfigHCmdShellScriptAction', AbstractShellScriptAction)

function module:initialize()
	AbstractShellScriptAction.initialize(self)
end

-- https://stackoverflow.com/questions/1015163/heredoc-for-windows-batch
-- https://stackoverflow.com/questions/7105433/windows-batch-echo-without-new-line
assert.globalTypeIsFunctionOrCall('ipairs')
function module:execute(shellScript, buildEnvironment, configHDefines, filePath)
	assert.parameterTypeIsInstanceOf('configHDefines', configHDefines, ConfigHDefines)
	local actualFilePath
	if filePath == nil then
		actualFilePath = './config.h'
	else
		assert.parameterTypeIsInstanceOf('filePath', filePath, Path)
		filePath:assertIsFilePath('filePath')
		
		actualFilePath = filePath:toString(true)
	end
	
	local lines = configHDefines:toCPreprocessorTextLines()
	for index, line in ipairs(lines) do
		
		local redirectionOperator
		if index == 1 then
			redirectionOperator = '>'
		else
			redirectionOperator = '>>'
		end
		
		shellScript:appendLinesToScript('ECHO ' .. shellScript:quoteArgument(line) .. ' ' .. redirectionOperator .. shellScript:quoteArgument(actualFilePath))
	end
end
