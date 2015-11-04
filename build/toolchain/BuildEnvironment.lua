--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local BuildEnvironment = moduleclass('BuildEnvironment')

local halimede = require('halimede')
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize
local Toolchain = requireSibling('Toolchain')
local BufferedShellScript = require('halimede.io.shellScript.BufferedShellScript')
local noRedirection = require('halimede.io.execute').noRedirection
local ConfigHDefines = require('halimede.build.defines.ConfigHDefines')


assert.globalTypeIsFunction('select', 'type', 'ipairs')
BuildEnvironment.static.addFileExtensionToFileNames = function(extensionWithLeadingPeriod, ...)
	local asTable
	if select('#', ...) == 1 then
		if type(...) == 'table' then
			asTable = select(1, ...)
		else
			asTable = {...}
		end
	else
		asTable = {...}
	end
	
	local result = tabelize()
	for _, basefilename in ipairs(asTable) do
		result:insert(basefilename .. extensionWithLeadingPeriod)
	end
	return result
end

function BuildEnvironment(buildToolchain, crossToolchain)
	self.buildToolchain = buildToolchain
	self.crossToolchain = crossToolchain
	
	if buildToolchain == crossToolchain then
		isCrossCompiling = false
	else
		isCrossCompiling = true
	end
	self.isCrossCompiling = isCrossCompiling
end

assert.globalTypeIsFunction('ipairs')
function module:use(isForRunningOnCrossCompiledHost, dependencies, buildVariant, sourcePath, platformConfigHDefinesFunctions, userFunction)
	assert.parameterTypeIsFunctionOrCall(userFunction)
	assert.parameterTypeIsBoolean(isForRunningOnCrossCompiledHost)
	assert.parameterTypeIsTable(dependencies)
	assert.parameterTypeIsTable(buildVariant)

	local toolchain
	if isForRunningOnCrossCompiledHost then
		toolchain = self.crossToolchain
	else
		toolchain = self.buildToolchain
	end
	
	local platform = toolchain.platform
	local configHDefines = platform:newConfigHDefines()
	for _, platformConfigHDefinesFunction in ipairs(platformConfigHDefinesFunctions) do
		platformConfigHDefinesFunction(configHDefines, platform)
	end
		
	local shellScript = self:_newShellScript(toolchain, dependencies, buildVariant)
	shellScript:newAction(nil, 'StartScript'):execute(sourcePath)
	
	local buildEnvironmentLight = {
		
		buildToolchain = self.buildToolchain,
		
		crossToolchain = self.crossToolchain,
		
		isCrossCompiling = self.isCrossCompiling,
		
		concatenateToPath = function(...)
			self.buildToolchain:concatenateToPath(...)
		end,
		
		addFileExtensionToFileNames = BuildEnvironment.addFileExtensionToFileNames,
		
		toCFiles = function(...)
			return BuildEnvironment.addFileExtensionToFileNames('.c', ...)
		end,

		-- TODO: not necessarily .cxx; several variants, sadly
		toCPlusPlusFiles = function(...)
			return BuildEnvironment.addFileExtensionToFileNames('.cxx', ...)
		end,
		
		action = function(name, namespace, ...)
			shellScript:newAction(namespace, name):execute(...)
		end,
		
		arguments = buildVariant.arguments,
		
		configHDefines = configHDefines
	}
	
	userFunction(buildEnvironmentLight)
	
	shellScript:newAction(nil, 'EndScript'):execute()
	shellScript:executeScriptExpectingSuccess(noRedirection, noRedirection)
end

-- Are we expecting shell scripts to execute on the build or on the cross?
function module:_newShellScript(toolchain, dependencies, buildVariant)
	local shellScriptExecutor = toolchain.platform.shellScriptExecutor
	return shellScriptExecutor:newShellScript(ToolchainBufferedShellScript, dependencies, buildVariant)
end
