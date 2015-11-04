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

function module:use(userFunction, isForRunningOnCrossCompiledHost, buildVariantArguments, configHDefines, sourcePath)
	assert.parameterTypeIsFunctionOrCall(userFunction)
	
	
	
	
	
	TODO: Still need to pass    dependencies, buildVariant   to ctor of compiler driver actions
	
	
	
	
	
	local shellScript = self:_newShellScript(isForRunningOnCrossCompiledHost)
	shellScript:newAction('StartScript')(sourcePath)
	
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
		end
	}
	
	userFunction(buildEnvironmentLight, buildVariantArguments, configHDefines)
	
	shellScript:newAction('EndScript')()
	shellScript:executeScriptExpectingSuccess(noRedirection, noRedirection)
end

-- Are we expecting shell scripts to execute on the build or on the cross?
function module:_newShellScript(isForRunningOnCrossCompiledHost)
	assert.parameterTypeIsBoolean(isForRunningOnCrossCompiledHost)
	
	local toolchain
	if isForRunningOnCrossCompiledHost then
		toolchain = self.crossToolchain
	else
		toolchain = self.buildToolchain
	end
	
	local shellScriptExecutor = toolchain.platform.shellScriptExecutor
	return shellScriptExecutor:newShellScript(ToolchainBufferedShellScript, toolchain)
end
