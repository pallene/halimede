--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ConfigHDefines = halimede.build.defines.ConfigHDefines
local Path = halimede.io.paths.Path
local AbstractCmdShellScriptAction = require.sibling('AbstractCmdShellScriptAction')


moduleclass('WriteConfigHCmdShellScriptAction', AbstractCmdShellScriptAction)

function module:initialize(shellScript)
	AbstractCmdShellScriptAction.initialize(self, shellScript)
end

-- https://stackoverflow.com/questions/1015163/heredoc-for-windows-batch
-- https://stackoverflow.com/questions/7105433/windows-batch-echo-without-new-line
assert.globalTypeIsFunction('ipairs')
function module:execute(configHDefines, filePath)
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
		
		self:_appendLinesToScript('ECHO ' .. self:_quoteArgument(line) .. ' ' .. redirectionOperator .. self:_quoteArgument(actualFilePath))
	end
end
