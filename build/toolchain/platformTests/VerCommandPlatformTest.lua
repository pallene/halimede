--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractCommandPlatformTest = halimede.build.toolchain.platformTests
local ShellLanguage = halimede.io.shellScript.ShellLanguage


halimede.moduleclass('VerCommandPlatformTest', AbstractCommandPlatformTest)

local validShellLanguages = {
	ShellLanguage.Cmd
}

function module:initialize()
	-- Or winver
	AbstractCommandPlatformTest.initialize(self, validShellLanguages, 'VER')
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function module:_interpret(rawData)
	
	-- See https://en.wikipedia.org/wiki/Ver_%28command%29 for known versions (note that they are not always logical; 3.1 is internally 3.10)
	-- Windows Vista is the first release to support soft symlinks, and should be our minimum supported version
	-- There is occasionally a fourth version number
	-- See env variable PROCESSOR_ARCHITECTURE
		-- May be x86 (32-bit), AMD64, IA64, and possible EM64T (Windows XP 64-bit)
		-- However, reflects the process's architecture, not that of Windows (however, that isn't necessarily bad)
		-- PROCESSOR_ARCHITEW6432 is defined on 64-bit machines to either IA64 or AMD64 (Windows 7 / 2008 onwards)
		-- https://msdn.microsoft.com/en-us/library/aa384274.aspx
	-- Also OS=Windows_NT
	
	-- It is not clear how we detect we're running under these things
	-- Cygwin (DONE)
	-- midipix
	-- https://en.wikipedia.org/wiki/UWIN
	-- UWIN
	-- MKS Toolkit
	-- UnxUtils
	-- GnuWin32
	-- MinGW (32 and 64 bit variants are very different)
		-- MSYS / GitBash
	-- DJGPP
	-- Interix / LBW / Windows Servers for Unix
	
--[[

Microsoft Windows [Version 6.0.6001]

--]]
	
	local versionString = rawData:match('Version ([0-9]+.[0-9]+.[0-9]+)')
	
	-- For all intents and purposes, we're compatible with majorVersion 6 or 10
	local versionData = versionString:split('.')
	local length = #versionData
	local majorVersion = versionData[1]
	local minorVersion
	if length == 1 then
		minorVersion = '0'
	else
		minorVersion = versionData[2]
	end
	local revisionVersion
	if length == 2 then
		buildVersion = '0'
	else
		buildVersion = versionData[3]
	end
	
	local lines = rawData:split('\n')
	if #lines ~= 2 then
		return false, 'Not exactly one line terminated by newline'
	end
	
	if #lines[2] ~= 0 then
		return false, 'Not exactly one line terminated by newline; subsequent line has content'
	end
	
	local line = lines[1]
	line:split(' ')
	if #line ~= 3 then
		return false, "Does not contain space-separated operating system implementation name (eg 'Darwin'), hardware type (eg 'x86_64') and release (eg '14.5.0')"
	end
	
	return {
		operatingSystemName = 'Windows',
		release = majorVersion
	}
end
