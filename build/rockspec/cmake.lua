--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local tabelize = halimede.table.tabelize
local exception = halimede.exception
local Path = halimede.io.paths.Path
local FileHandleStream = halimede.io.FileHandleStream


local cmakeEnvironmentVariables = {
	'CMAKE_MODULE_PATH',
	'CMAKE_LIBRARY_PATH',
	'CMAKE_INCLUDE_PATH'
}

local function assertTableOrEmpty(value)
	if value == nil then
		return {}
	end
	assert.parameterTypeIsTable('value', value)
	return value
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('os', 'getenv')
assert.globalTypeIsFunctionOrCall('tostring')
function module.cmakebuild(rockspec, parentFolderOfCmakeListsPath)
	assert.parameterTypeIsTable('rockspec', rockspec)
	assert.parameterTypeIsInstanceOf('parentFolderOfCmakeListsPath', parentFolderOfCmakeListsPath, Path)
	
	parentFolderOfCmakeListsPath:assertIsFilePath('parentFolderOfCmakeListsPath')
	
	local build = assertTableOrEmpty(rockspec.build)
	
	local buildVariables = assertTableOrEmpty(build.variables)
	
	for _, environmentVariable in ipairs(cmakeEnvironmentVariables) do
		buildVariables[environmentVariable] = os.getenv(environmentVariable)
	end
	
	local rockspecVariables = assertTableOrEmpty(rockspec.variables)
	makeStyleVariableSubstitutions(buildVariables, assertTableOrEmpty(rockspecVariables))
	
	local function createCMakeListsIfRequired()
		local cmakeListsContent = build.cmake
		if type.isString(cmakeListsContent) then
			local cmakeListsFilePath = rockspec, parentFolderOfCmakeListsPath:appendFile('CMakeLists', 'txt')
			
			local fileHandleStream = FileHandleStream.openTextFileForWriting(cmakeListsFilePath, 'CMakeLists file')
			fileHandleStream:writeAllContentsAndClose(cmakeListsContent)
		end
	end
	createCMakeListsIfRequired()
	
	local function guardCmakeBinaryExists()
		local cmakeBinaryName = rockspecVariables.CMAKE
		programExists(cmakeBinaryName, '--version')
		return cmakeBinaryName
	end
	local cmakeBinaryName = guardCmakeBinaryExists()
	
	local function executeCmake()
		local cmakeArguments = tabelize()
	
		cmakeArguments:insert(cmakeBinaryName)
	
		cmakeArguments:insert('-H.')
		cmakeArguments:insert('-Bbuild.luarocks')
		-- seems to get this from cfg, with a weird windows hack
		local cmakeGenerator = ?
		cmakeArguments:insert('-G' .. cmakeGenerator)
		for key, value in buildVariables do
			cmakeArguments:insert('-D' .. key .. '=' .. tostring(value))
		end
		
		executeAndDisplayOutputOnFailure(cmakeArguments)
	end
	
	local function buildCmake()
		executeAndDisplayOutputOnFailure(cmakeBinaryName, '--build', 'build.luarocks', '--config', 'Release')
	end
	buildCmake()
	
	local function installCmake()
		executeAndDisplayOutputOnFailure(cmakeBinaryName, '--build', 'build.luarocks', '--config', 'Release', '--target', 'install')
	end
	installCmake()
	
end

function module.commandbuild(rockspec, rockspecFilePath)
	assert.parameterTypeIsTable('rockspec', rockspec)
	assert.parameterTypeIsString('rockspecFilePath', rockspecFilePath)
	
	local build = assertTableOrEmpty(rockspec.build)
	
end



-- "$(XYZ)" will have this substring replaced by vars["XYZ"]
local makeVariableFormatPattern = '%$%((%a[%a%d_]+)%)'
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gsub')
function module.makeStyleVariableSubstitutions(makeReplacementsIntoHereWith, variables)
	assert.parameterTypeIsTable('makeReplacementsIntoHereWith', makeReplacementsIntoHereWith)
	assert.parameterTypeIsTable('variables', variables)
   
    local updated = {}
    for key, value in pairs(makeReplacementsIntoHereWith) do
		if type.isString(value) then
			local line = value:gsub(makeVariableFormatPattern, variables)
			throwExceptionIfThereAreFailingMatches(line)
			updated[key] = line
		end
	end
	for key, value in pairs(updated) do
		makeReplacementsIntoHereWith[key] = value
	end
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'gmatch')
local function throwExceptionIfThereAreFailingMatches(line)
	local hasFailingMatches = false
	local failingMatches = tabelize()
	for unmatchedMakeVariable in line:gmatch(makeVariableFormatPattern) do
		failingMatches:insert(unmatchedMakeVariable)
	end
	
	local numberOfFailingMatches = #failingMatches
	if numberOfFailingMatches ~= 0 then
		local plural
		if numberOfFailingMatches == 1 then
			plural = 'es'
		else
			plural = ''
		end
		exception.throw("There are %s failing match%s: '%s'", numberOfFailingMatches, plural, failingMatches:concat(", "))
	end
end

local function programExists(....)
	error("Implement me!")
end

-- Write to a temporary file or two
local function executeAndDisplayOutputOnFailure(....)
	error("Implement me!")
end
