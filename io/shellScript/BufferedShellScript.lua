--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local BufferedShellScript = moduleclass('BufferedShellScript')

local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local tabelize = require('halimede.table.tabelize').tabelize
local deepCopy = require('halimede.table.deepCopy').deepCopy
local ShellLanguage = require('halimede.io.ShellLanguage')
local ShellScriptExecutor = require('halimede.io.shellScript.ShellScriptExecutor')
local toTemporaryFileAllContentsInTextModeAndUse = require('halimede.io.temporaryWrite').toTemporaryFileAllContentsInTextModeAndUse


function BufferedShellScript:initialize(shellLanguage)
	assert.parameterTypeIsInstanceOf(shellLanguage, ShellLanguage)
	
	self.shellLanguage = shellLanguage
	self.tabelizedScriptBuffer = tabelize()
end

function BufferedShellScript:appendLinesToScript(...)
	self.shellLanguage:appendLinesToScript(self.tabelizedScriptBuffer, ...)
end

function BufferedShellScript:appendCommandLineToScript(tabelizedScriptBuffer, ...)
	self.shellLanguage:appendCommandLineToScript(self.tabelizedScriptBuffer, ...)
end

function BufferedShellScript:finish()
	local script = self.tabelizedScriptBuffer:concat()
	self.tabelizedScriptBuffer = tabelize()
	return script
end

function BufferedShellScript:executeScriptExpectingSuccess(shellScriptExecutor, standardOut, standardError)
	assert.parameterTypeIsInstanceOf(shellLanguage, ShellScriptExecutor)
	
	local script = self:finish()
	
	toTemporaryFileAllContentsInTextModeAndUse(script, self.shellLanguage.shellScriptFileExtensionIncludingLeadingPeriod, function(scriptFilePath)
		shellScriptExecutor:executeScriptExpectingSuccess(scriptFilePath, standardOut, standardError)
	end)
end
