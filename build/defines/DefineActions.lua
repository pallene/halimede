--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local AbstractDefineValue = halimede.build.defines.defineValues.AbstractDefineValue
local ShellArgument = halimede.io.shellScript.ShellArgument


function module.ExplicitlyUndefine(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	return {
		toShellArgumentLines = function(shellLanguage)
			return {ShellArgument:new(shellLanguage:escapeToShellSafeString('#undef ' .. defineName))}
		end,
		
		appendToCompilerDriverArguments = function(shellLanguage, compilerDriverArguments)
			compilerDriverArguments:undefinePreprocessorMacro(defineName)
		end
	}
end

function module.Undefine(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	return {
		toShellArgumentLines = function(shellLanguage)
			return {ShellArgument:new(shellLanguage:escapeToShellSafeString('/* #undef ' .. defineName .. ' */'))}
		end,
		
		appendToCompilerDriverArguments = function(shellLanguage, compilerDriverArguments)
		end
	}
end

local function toShellArgument(prefix, defineName, defineValue, shellLanguage)
	local prepend = prefix .. '#define ' .. defineName .. ' '
	return defineValue:toShellArgument(prepend, shellLanguage)
end

function module.Define(defineName, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsInstanceOf('defineValue', defineValue, AbstractDefineValue)
	
	return {
		toShellArgumentLines = function(shellLanguage)
			return {toShellArgument('', defineName, defineValue, shellLanguage)}
		end,
		
		appendToCompilerDriverArguments = function(shellLanguage, compilerDriverArguments)
			local defineValueShellArgument = defineValue:toShellArgument('', shellLanguage)
			compilerDriverArguments:definePreprocessorMacro(defineName, defineValueShellArgument)
		end
	}
end

function module.IfndefDefine(defineName, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsInstanceOf('defineValue', defineValue, AbstractDefineValue)
	
	return {
		toShellArgumentLines = function(shellLanguage)
			return {
				ShellArgument:new(shellLanguage:escapeToShellSafeString('#ifndef ' .. defineName)),
				toShellArgument('\t', defineName, defineValue, shellLanguage),
				ShellArgument:new(shellLanguage:escapeToShellSafeString('#endif'))
			}
		end,
		
		appendToCompilerDriverArguments = function(shellLanguage, compilerDriverArguments)
			exception.throw("#ifndef style definitions are not supported for the compiler driver command line")
		end
	}
end
