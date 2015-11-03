--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local tabelize = require('halimede.table.tabelize').tabelize
local deepCopy = require('halimede.table.deepCopy').deepCopy
local ShellLanguage = require('halimede.io.ShellLanguage')
local execute = require('halimede.io.execute')
local executeExpectingSuccess = execute.executeExpectingSuccess
local noRedirection = execute.noRedirection


local BuildMachine = class('BuildMachine')

function BuildMachine:initialize(shellLanguage, shellScriptExecutionCommand)
	assert.parameterTypeIsTable(shellLanguage)
	assert.parameterTypeIsTable(shellScriptExecutionCommand)
	
	self.shellLanguage = shellLanguage
	self.shellScriptExecutionCommand = tabelize(shellScriptExecutionCommand)
end

assert.globalTypeIsFunction('unpack')
function BuildMachine:executeScript(scriptFilePath)
	assert.parameterTypeIsString(scriptFilePath)
	
	local arguments = deepCopy(self.shellScriptExecutionCommand)
	arguments:insert(scriptFilePath)
	
	executeExpectingSuccess(noRedirection, noRedirection, noRedirection, unpack(arguments))
end

BuildMachine.static.POSIX = BuildMachine:new(ShellLanguage.POSIX, {'sh'})
BuildMachine.static.Windows = BuildMachine:new(ShellLanguage.Windows, {'cmd', '/c', '/e:on', '/u'})
BuildMachine.static.MacOsXHomebrew = BuildMachine:new(ShellLanguage.POSIX, {'brew' 'sh'})
BuildMachine.static.MacOsXHomebrew.executeScript = function(self, scriptFilePath)
	executeExpectingSuccess(scriptFilePath, noRedirection, noRedirection, 'brew', 'sh')
end

return BuildMachine
