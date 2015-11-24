--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local configure = halimede.luacode.configure
local deepMerge = halimede.table.deepMerge.deepMerge
local isTable = type.isTable

assert.globalTypeIsFunction('setmetatable')
local platformsInOrderByOperatingSystem = setmetatable({
	FreeBSD = {'unix', 'bsd', 'freebsd'},
	OpenBSD = {'unix', 'bsd', 'openbsd'},
	NetBSD =  {'unix', 'bsd', 'netbsd'},
	Darwin =  {'unix', 'bsd', 'macosx'},
	Linux =   {'unix', 'linux'},
	SunOS =   {'unix', 'solaris'},
	CYGWIN =  {'unix', 'cygwin'},
	Windows = {'windows', 'win32'}
	MINGW   = {'windows', 'mingw32', 'win32'}
}, {__index = function(_, operatingSystem)
	assert.parameterTypeIsString('operatingSystem', operatingSystem)
	
	return 'unix'
end})

local platformOverrideNames = {
	'build',
	'dependencies',
	'external_dependencies',
	'source',
	'hooks'
}

local function applyPlatformOverrides(rockspec, operatingSystem)
	
	local platformsInOrder = platformsInOrderBySystem[operatingSystem]
	
	-- eg rockspec.build.platforms.unix.* merges with rockspec.build.* 
	for _, platformOverrideName in ipairs(platformOverrideNames) do
		
		local subRockspec = rockspec[platformOverrideName]
		if isTable(subRockspec) then
		
			local subRockspecPlatforms = subRockspec.platforms
			if isTable(subRockspecPlatforms) then
			
				for _, platform in ipairs(platformsInOrder) do
				
					local subRockspecPlatform = subRockspecPlatforms[platform]
					if isTable(subRockspecPlatform) then
					
						deepMerge(subRockspecPlatform, subRockspec)
					
					end
				
				end
			
			end
			
		end
	end
end

function module.loadRockspec(rockspecFilePath, operatingSystem)
	assert.parameterTypeIsString('rockspecFilePath', rockspecFilePath)
	assert.parameterTypeIsString('operatingSystem', operatingSystem)
	
	local chunkResult, rockspec = configure.load('rockspec file', rockspecFilePath, {}, {}, configure.sandboxEnvironmentToPreserve)
	applyPlatformOverrides(rockspec, operatingSystem)
	
	return rockspec
end
