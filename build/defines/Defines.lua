--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = halimede.io.paths.Path


moduleclass('Defines')

function module:initialize()
	self.defines = {}
	self.explicitlyUndefine = {}
end

function module:explicitlyUndefine(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	self.explicitlyUndefine[defineName] = true
end

function module:undefine(defineName)
	assert.parameterTypeIsString('defineName', defineName)
	
	self.defines[defineName] = nil
end

function module:boolean(defineName, enable)
	assert.parameterTypeIsBoolean('enable', enable)
	
	if enable then
		self.defines[defineName] = '1'
	else
		self:undefine(defineName)
	end
end

function module:oneOrZero(defineName, enable)
	assert.parameterTypeIsBoolean('enable', enable)
	
	if enable then
		self.defines[defineName] = '1'
	else
		self.defines[defineName] = '0'
	end
end

function module:defineIfMissing(defineName, enable, defineValue)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsBoolean('enable', enable)
	
	if enable then
		self:undefine(defineName)
	else
		self.defines[defineName] = defineValue
	end
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
function module:quotedNonEmptyString(defineName, value)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsStringOrNil('value', value)
	
	if value == nil then
		self:undefine(defineName)
	else
		if value:isEmpty() then
			exception.throw("The '%s' define can not be empty", defineName)
		end
		self.defines[defineName] = '"' .. value .. '"'
	end	
end

function module:quotedPathString(defineName, value)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsInstanceOfOrNil('value', value, Path)
	
	if value == nil then
		self:undefine(defineName)
	else
		self.defines[defineName] = '"' .. value:toString(true) .. '"'
	end	
end

function module:enumeration(defineName, enumeratedConstant, prefix)
	assert.parameterTypeIsString('defineName', defineName)
	assert.parameterTypeIsStringOrNil('prefix', prefix)
	
	if prefix == nil then
		prefix = 'halimede.build.defines.'
	end
	
	if enumeratedConstant == nil then
		self:undefine(defineName)
	else
		local enumerationClass = require(prefix .. defineName)
		assert.parameterTypeIsInstanceOf('enumeratedConstant', enumeratedConstant, enumerationClass)
		self.defines[defineName] = enumeratedConstant.value
	end
end
