--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local tabelize = halimede.table.tabelize
local isInstanceOf = halimede.type.isInstanceOf
local Path = halimede.io.paths.Path
local ShellPath = halimede.io.shellScript.ShellPath
local sibling = halimede.build.defines
local DefineActions = sibling.DefineActions
local ExplicitlyUndefine = DefineActions.ExplicitlyUndefine
local Undefine = DefineActions.Undefine
local Define = DefineActions.Define
local IfndefDefine = DefineActions.IfndefDefine
local defineValues = sibling.defineValues
local AbstractDefineValue = defineValues.AbstractDefineValue
local StringDefineValue = defineValues.StringDefineValue
local QuotedStringDefineValue = defineValues.QuotedStringDefineValue
local QuotedCharacterDefineValue = defineValues.QuotedCharacterDefineValue
local EnumerationDefineValue = defineValues.EnumerationDefineValue
local QuotedPathDefineValue = defineValues.QuotedPathDefineValue
local QuotedShellPathDefineValue = defineValues.QuotedShellPathDefineValue


local Zero = StringDefineValue:new('0')
local One = StringDefineValue:new('1')
local Two = StringDefineValue:new('2')

halimede.moduleclass('Defines')

function module:initialize()
	self.haveBeenDefinedExplicitly = {}
	self.actions = tabelize()
end

function module:_undefineIfPreviouslyDefined(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	local action
	if self.haveBeenDefinedExplicitly[defineName] then
		self.haveBeenDefinedExplicitly[defineName] = nil
		action = ExplicitlyUndefine(defineName)
	else
		action = Undefine(defineName)
	end
	self.actions:insert(action)
end

function module:_define(defineName, defineValue)
	self.haveBeenDefinedExplicitly[defineName] = true
	self.actions:insert(Define(defineName, defineValue))
end

function module:explicitlyUndefine(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	self.haveBeenDefinedExplicitly[defineName] = nil
	self.actions:insert(ExplicitlyUndefine(defineName))
end

function module:_ensureDefinition(defineName, enable, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsBoolean('enable', enable)
	assert.parameterTypeIsInstanceOf('defineValue', defineValue, AbstractDefineValue)

	if enable then
		self:_define(defineName, defineValue)
	else
		self.haveBeenDefinedExplicitly[defineName] = true
		self.actions:insert(IfndefDefine(defineName, defineValue))
	end
end

local DefaultPrefix = 'halimede.build.defines.'
assert.globalTypeIsFunctionOrCall('require')
function module:enumeration(defineName, enumeratedConstant, prefix)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsStringOrNil('prefix', prefix)

	if enumeratedConstant == nil then
		self:_undefineIfPreviouslyDefined(defineName)
	else
		local enumerationClass = require((prefix or DefaultPrefix) .. defineName)
		self:_define(defineName, EnumerationDefineValue:new(enumeratedConstant, enumerationClass))
	end
end

-- Exists to ensure things like 'const' and 'uid_t' are defined
function module:defineIfMissing(defineName, enable, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsBoolean('enable', enable)
	assert.parameterTypeIsInstanceOf('defineValue', defineValue, AbstractDefineValue)
	
	if enable then
		self:_define(defineName, defineValue)
	end
end

function module:boolean(defineName, enable)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsBoolean('enable', enable)

	if enable then
		self:_define(defineName, One)
	else
		self:_undefineIfPreviouslyDefined(defineName)
	end
end

function module:booleanAsTwo(defineName, enable)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsBoolean('enable', enable)

	if enable then
		self:_define(defineName, Two)
	else
		self:_undefineIfPreviouslyDefined(defineName)
	end
end

function module:oneOrZero(defineName, enable)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsBoolean('enable', enable)

	if enable then
		self:_define(defineName, One)
	else
		self:_define(defineName, Zero)
	end
end

function module:quotedCharacter(defineName, value)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsStringOrNil('value', value)

	if value == nil then
		self:_undefineIfPreviouslyDefined(defineName)
	else
		if #value ~= 1 then
			exception.throw("The '%s' define must be exactly one character, it can not be '%s'", defineName, value)
		end
		self:_define(defineName, QuotedCharacterDefineValue:new(value))
	end
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
function module:quotedNonEmptyString(defineName, value)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsStringOrNil('value', value)

	if value == nil then
		self:_undefineIfPreviouslyDefined(defineName)
	else
		if value:isEmpty() then
			exception.throw("The '%s' define can not be empty", defineName)
		end
		self:_define(defineName, QuotedStringDefineValue:new(value))
	end
end

function module:quotedPathString(defineName, value)
	assert.parameterTypeIsString('defineName', defineName)
	
	if value == nil then
		self:_undefineIfPreviouslyDefined(defineName)
		return
	end
	
	local defineValue
	if isInstanceOf(value, Path) then
		defineValue = QuotedPathDefineValue:new(value)
	elseif isInstanceOf(value, ShellPath) then
		defineValue = QuotedShellPathDefineValue:new(value)
	else
		exception.throw("value '%s' is not nil, a Path or a ShellPath", value)
	end
	self:_define(defineName, defineValue)
end
