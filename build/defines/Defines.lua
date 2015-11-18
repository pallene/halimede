--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Defines = moduleclass('Defines')

local halimede = require('halimede')
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize


function Defines:initialize()
	self.defines = {}
	self.explicitlyUndefine = {}
end

function Defines:_explicitlyUndefine(defineName)
	self.explicitlyUndefine[defineName] = true
end

function Defines:_undefine(defineName)
	self.defines[defineName] = nil
end

function Defines:_boolean(defineName, enable)
	assert.parameterTypeIsBoolean('enable', enable)
	
	if enable then
		self.defines[defineName] = '1'
	else
		self:_undefine(defineName)
	end
end

function Defines:_oneOrZero(defineName, enable)
	assert.parameterTypeIsBoolean('enable', enable)
	
	if enable then
		self.defines[defineName] = '1'
	else
		self.defines[defineName] = '0'
	end
end

function Defines:_defineIfMissing(defineName, enable, defineValue)
	if enable then
		self:_undefine(defineName)
	else
		self.defines[defineName] = defineValue
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'isEmpty')
function Defines:quotedNonEmptyString(defineName, value)
	if constant == nil then
		self:_undefine(defineName)
	else
		assert.parameterTypeIsString('value', value)
		if character:isEmpty() then
			exception.throw("The %s define can not be empty", defineName)
		end
		self.defines[defineName] = "'" .. command "'"
	end	
end

local enumerationClassParentModulePrefix
if parentModuleName == '' then
	enumerationClassParentModulePrefix = ''
else
	enumerationClassParentModulePrefix = parentModuleName .. '.'
end
function Defines:_enumeration(defineName, constant)
	if constant == nil then
		self:_undefine(defineName)
	else
		local enumerationClass = require(enumerationClassParentModulePrefix .. defineName)
		assert.parameterTypeIsInstanceOf('constant', constant, enumerationClass)
		self.defines[defineName] = constant.value
	end
end
