--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local AbstractDefineValue = halimede.builddefines.defineValues.AbstractDefineValue


function module.ExplicitlyUndefine(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	return {
		toCPreprocessorTextLines = function()
			return {'#undef ' .. defineName}
		end,
		
		appendToCompilerDriverArguments = function(compilerDriverArguments)
			compilerDriverArguments:undefinePreprocessorMacro(defineName)
		end
	}
end

function module.Undefine(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	return {
		toCPreprocessorTextLines = function()
			return {'/* #undef ' .. defineName .. ' */'}
		end,
		
		appendToCompilerDriverArguments = function(compilerDriverArguments)
		end
	}
end

function module.Define(defineName, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsInstanceOf('defineValue', defineValue, AbstractDefineValue)
	
	return {
		toCPreprocessorTextLines = function()
			return {'#define ' .. defineName .. ' ' .. defineValue}
		end,
		
		appendToCompilerDriverArguments = function(compilerDriverArguments)
			defineValue:appendToCompilerDriverArguments(defineName, compilerDriverArguments)
		end
	}
end

function module.IfndefDefine(defineName, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsInstanceOf('defineValue', defineValue, AbstractDefineValue)
	
	return {
		toCPreprocessorTextLines = function()
			return {
				'#ifndef ' .. defineName,
				'\t#define ' .. defineName .. ' ' .. defineValue,
				'#endif'
			}
		end,
		
		appendToCompilerDriverArguments = function(compilerDriverArguments)
			exception.throw("#ifndef style definitions are not supported for the compiler driver command line")
		end
	}
end
