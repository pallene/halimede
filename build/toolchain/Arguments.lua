--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = halimede.table.tabelize
local ShellLanguage = halimede.io.shellScript.ShellLanguage
local ShellScript = halimede.io.shellScript.ShellScript
local isTable = halimede.type.isTable


halimede.moduleclass('Arguments')

function module:initialize(shellLanguage)
	assert.parameterTypeIsInstanceOf('shellLanguage', shellLanguage, ShellLanguage)

	self.shellLanguage = shellLanguage

	self.arguments = tabelize()
end

function module:_append(argument)
	assert.parameterTypeIsString('argument', argument)
	self.arguments:insert(argument)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:append(...)
	local arguments = {...}
	for _, argument in ipairs(arguments) do
		if isTable(argument) then
			for _, actualArgument in ipairs(argument) do
				self:_append(actualArgument)
			end
		else
			self:_append(argument)
		end
	end
end

function module:appendQuotedArgumentXWithPrepend(text, pathLike, specifyCurrentDirectoryExplicitlyIfAppropriate)
	assert.parameterTypeIString('text', text)
	assert.parameterTypeIsTable('pathLike', pathLike)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)

	self:_append(pathLike:toQuotedShellArgumentX(specifyCurrentDirectoryExplicitlyIfAppropriate, self.shellLanguage):prepend(text))
end

assert.globalTypeIsFunctionOrCall('unpack')
function module:appendCommandLineToScript(shellScript)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)

	shellScript:appendCommandLineToScript(unpack(self.arguments))
end
