--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert


local prefix = 'halimede.build.toolchain.operatingSystems.'
assert.globalTypeIsFunctionOrCall('require')
local function load(class)
	return require(prefix .. class)
end


local classes = {
	'WindowsOperatingSystem',
	'LegacyOperatingSystem',
	'PosixOperatingSystem',
	'HypenatedRevisionPosixOperatingSystem',
	'DotRevisionPosixOperatingSystem',
	'UnixOnWindowsOperatingSystem',
	'PrefixedUnixOnWindowsOperatingSystem',
	'CywinLikePrefixedUnixOnWindowsOperatingSystem'
}

assert.globalTypeIsFunctionOrCall('ipairs')
for _, class in ipairs(classes) do
	load(class)
end


local knownOperatingSystems = load('OperatingSystem').knownOperatingSystems
local knownOperatingSystemsRegistered = false
local legacy = {}
local startsWith = {}
local exactlyMatches = {}

assert.globalTypeIsFunctionOrCall('ipairs', 'pairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'sub', 'find')
function module.extractOperatingSystemFromUname(sSwitchText)
	assert.parameterTypeIsString('sSwitchText', sSwitchText)
	
	if not knownOperatingSystemsRegistered then
		for _, knownOperatingSystem in ipairs(knownOperatingSystems) do
			knownOperatingSystem:register(legacy, startsWith, exactlyMatches)
		end
		knownOperatingSystemsRegistered = true
	end
	
	local legacyOperatingSystem = legacy[sSwitchText]
	if legacyOperatingSystem ~= nil then
		return nil, "Legacy operating systems such as '" .. sSwitchText .. "' are not supported"
	end
	
	for prefix, startsWithOperatingSystem in pairs(startsWith) do
		if sSwitchText:sub(1, #prefix) == prefix then
			return startsWithOperatingSystem
		end
	end
	
	local exactMatchOperatingSystem = exactlyMatches[sSwitchText]
	if legacyOperatingSystem ~= nil then
		return exactMatchOperatingSystem
	end
	
	return nil, "Could not identify an operating system for uname -m '" .. sSwitchText .. "'"
end
