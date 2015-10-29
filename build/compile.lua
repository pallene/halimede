--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local tabelize = require('halimede.table.tabelize').tabelize
local halimede = require('halimede')
local assert = halimede.assert
local exception = require('halimede.exception')

function module.writeConfigH()
	
end






local function writeCompilationScriptPreamble(sourcePath)
	assert.parameterTypeIsInstanceOf(sourcePath, AbsolutePath)
	
	script = [[
#!/usr/bin/env sh

set -e
set -u
set -f
]]

	return script .. shellLanguage.toShellCommand('cd', sourcePath.path) .. '\n'
end

assert.globalTypeIsFunction('ipairs')
local function addFlags(arguments, flags)
	for _, flag in flags do
		assert.parameterTypeIsString(flag)
		arguments:insert(flag)
	end
end

-- TODO: PATH
assert.globalTypeIsFunction('unpack', 'pairs')
function module.compilerDriverPreprocessAndCompile(script, shellLanguage, compilerDriver, sysrootPath, compilerDriverFlags, standard, preprocessorFlags, defines, sources)
	assert.parameterTypeIsString(script)
	assert.parameterTypeIsTable(shellLanguage)
	assert.parameterTypeIsTable(compilerDriver)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	assert.parameterTypeIsTable(compilerDriverFlags)
	assert.parameterTypeIsString(standard)
	assert.parameterTypeIsTable(preprocessorFlags)
	assert.parameterTypeIsTable(defines)
	assert.parameterTypeIsTable(sources)
	
	-- The compilerDriver is an array, eg {'gcc', '--sysroot=xxxx'}
	local arguments = tabelize({})
	addFlags(compilerDriver)
	arguments:insert('--sysroot=' .. sysrootPath.path)
	arguments:insert('-c')
	arguments:insert('-std=' .. standard)
	addFlags(arguments, compilerDriverFlags)
	addFlags(arguments, preprocessorFlags)
	for defineName, defineValue in pairs(defines) do
		assert.parameterTypeIsString(defineName)
		
		if type(defineValue) == 'boolean' then
			if defineValue == false then
				exception.throw("The define '%s' can not be a boolean false", defineName)
			end
			arguments:insert('-D' .. defineName)
		else
			assert.parameterTypeIsString(defineValue)
			arguments:insert('-D' .. defineName .. '=' .. defineValue)
		end
	end
	addFlags(arguments, sources)
	
	return script
	.. 'unset GCC_EXEC_PREFIX' .. '\n'
	.. shellLanguage.toShellCommand(unpack(arguments)) .. '\n'
end

function module.compilerDriverLinkExecutable()
	
end
