--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local InstructionSet = halimede.build.toolchain.InstructionSet
local tabelize = halimede.table.tabelize
local exception = halimede.exception


local OperatingSystem = halimede.moduleclass('OperatingSystem')

local knownOperatingSystems = {}
OperatingSystem.static.knownOperatingSystems = knownOperatingSystems

assert.globalTypeIsFunctionOrCall('pairs')
function module:initialize(normalisedUnameOperatingSystemName, description, architectures, isRunningOnWindows, isPosixAlike, hasBsdUserspace)
	assert.parameterTypeIsString('normalisedUnameOperatingSystemName', normalisedUnameOperatingSystemName)
	assert.parameterTypeIsString('description', description)
	assert.parameterTypeIsTable('architectures', architectures)
	assert.parameterTypeIsBoolean('isRunningOnWindows', isRunningOnWindows)
	assert.parameterTypeIsBoolean('isPosixAlike', isPosixAlike)
	assert.parameterTypeIsBoolean('hasBsdUserspace', hasBsdUserspace)  -- Needs expanding somewhat, but could become an object that represents how to do common things with sed (-i problem, extended regex problems), tar, default shell, od / hex differences, etc. That said, we want to minimise the use of the shell. grep, awk and sed should be redundant with lua. Indeed, replacing most of coreutils with Lua or LuaJIT variants makes moving to new platforms much, much easier...
	
	self.normalisedUnameOperatingSystemName = normalisedUnameOperatingSystemName
	self.description = description
	self.isRunningOnWindows = isRunningOnWindows
	self.isPosixAlike = isPosixAlike
	self.isBsdDerivative = isBsdDerivative
	
	local instructionSets = {}
	for name, architecture in pairs(architectures) do
		instructionSets[name] = InstructionSet[architecture]
	end
	self.instructionSets = instructionSets
	
	knownOperatingSystems:insert(self)
end

function module:_createVersion(major, minor, revision, subsytem)
	return {
		major = major,
		minor = minor,
		revision = revision,
		subsystem = subsystem
	}
end

function module:registerUname(legacy, startsWith, exactlyMatches)
	assert.parameterTypeIsTable('legacy', legacy)
	assert.parameterTypeIsTable('startsWith', startsWith)
	assert.parameterTypeIsTable('exactlyMatches', exactlyMatches)
	
	return self:_registerUname(legacy, startsWith, exactlyMatches)
end

-- Default implementation
function module:_registerUname(legacy, startsWith, exactlyMatches)
	if exactlyMatches[self.normalisedUnameOperatingSystemName] ~= nil then
		exception.throw("Already registered exact match '%s'", self.normalisedUnameOperatingSystemName)
	end
	exactlyMatches[self.normalisedUnameOperatingSystemName] = self
end

function module:extractArchitectureFromUnameOrWindowsEnvironmentVariable(mSwitchText)
	assert.parameterTypeIsStringOrNil('mSwitchText', mSwitchText)
	
	if mSwitchText == nil then
		return nil
	end
	
	return self.instructionSets[mSwitchText]
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'split')
function module:extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	assert.parameterTypeIsStringOrNil('sSwitchText', sSwitchText)
	assert.parameterTypeIsStringOrNil('rSwitchText', rSwitchText)
	assert.parameterTypeIsStringOrNil('vSwitchText', vSwitchText)
	
	if sSwitchText == nil or rSwitchText == nil or vSwitchText == nil then
		return nil
	end
	
	return self:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'split')
function module:extractVersioningFromVer(verText)
	assert.parameterTypeIsStringOrNil('verText', verText)
	
	if verTest == nil then
		return nil
	end
	
	local versionString = verText:match('Version ([0-9]+.[0-9]+.[0-9]+)')
	if versionString == nil then
		return nil
	end
	
	-- For all intents and purposes, we're compatible with majorVersion 6 or 10
	local versionData = versionString:split('.')
	local major = versionData[1]
	local minor = versionData[2]
	local revision = versionData[3]
	
	return self:_createVersion(major, minor, revision, nil)
end

-- TODO: Midipix, HP-UX, AIX, NONSTOP_KERNEL, OS400, OS/390, GNU, QNX
-- HP-UX: https://www.siteox.com/cart.php?gid=17 ($20 / day or $300 / month)
-- AIX: http://lparbox.com/ ($169 / month)
-- AIX: https://www.siteox.com/cart.php?gid=17 ($20 / day)
