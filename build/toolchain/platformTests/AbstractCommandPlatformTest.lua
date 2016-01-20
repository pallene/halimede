--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local tabelize = halimede.table.tabelize
local shellLanguage = halimede.io.shellScript.ShellLanguage.default()


local AbstractCommandPlatformTest = halimede.moduleclass('AbstractCommandPlatformTest')

assert.globalTypeIsFunctionOrCall('pcall')
AbstractCommandPlatformTest.static.executeCommand = function(...)
	local function popen()
		return shellLanguage:popenReadingFromSubprocess(shellLanguage.silenced, shellLanguage.silenced, ...)
	end
	local ok, errorOrFileHandleStream = pcall(popen)
	if not ok then
		return false, errorOrFileHandleStream
	end
	
	local function readAll()
		return fileHandleStream:readAllRemainingContentsAndClose()
	end
	ok, errorOrRawData = pcall(readAll)
	if not ok then
		return false, errorOrRawData
	end
	
	return true, errorOrRawData
end

function module:initialize(validShellLanguages, command, ...)
	assert.parameterTypeIsTable('validShellLanguages', validShellLanguages)
	assert.parameterTypeIsString('command', command)
	
	if #validShellLanguages == 0 then
		exception.throw("validShellLanguages can not be empty")
	end
	
	self.validShellLanguages = validShellLanguages
	self.command = command
	self.parameters = {...}
	
	local commandLine = tabelize({...})
	commandLine:insert(1, commnd)
	self.commandLine = commandLine
end

function module:isTestValid()
	return self:isValidOnCurrentShell() and shellLanguage:commandIsOnPathAndShellIsAvailableToUseIt(self.command)
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:isValidOnCurrentShell()
	for _, validShellLanguages in ipairs(self.validShellLanguages) do
		if shellLanguage == validShellLanguages then
			return true
		end
	end
	return false
end

assert.globalTypeIsFunctionOrCall('unpack', 'pcall')
function module:executeTest()
	local ok, errorOrRawData = AbstractCommandPlatformTest.executeComand(unpack(self.commandLine))
	if ok then
		return ok, self:interpret(errorOrRawData)
	else
		return false, errorOrRawData
	end
end

function module:_interpret(rawData)
	exception.throw('Abstract Method')
end

-- What things do we want to test for?
	-- Operating System Name
	-- Operating System Version (Major, Minor, Revision)
	-- GNU Tuple related
	-- Presence of programs
		-- gcc, version details
		-- clang, version details
		-- shell, version details
		-- etc