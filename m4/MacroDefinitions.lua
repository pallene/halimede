--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local Trie = halimede.collections.Trie
local AbstractMacroDefinition = halimede.m4.macroDefinitions.AbstractMacroDefinition
local tabelize = halimede.table.tabelize


halimede.moduleclass('MacroDefinitions')

local DefaultMacroNamePattern = '[_a-zA-Z][_a-zA-Z0-9]*'

function module:initialize(macroNamePattern)
	assert.parameterTypeIsStringOrNil('macroNamePattern', macroNamePattern)

	if macroNamePattern == nil then
		self.macroNamePattern = DefaultMacroNamePattern
	else
		self.macroNamePattern = macroNamePattern
	end

	self.definitionsRoot = Trie:new()
end

function module:define(macro)
	assert.parameterTypeIsInstanceOf('macro', macro, AbstractMacroDefinition)

	local macroName = macro.name
	local existingStackOfMacroDefinitions = self.definitionsRoot:get(macroName)
	if existingStackOfMacroDefinitions == nil then
		local stackOfMacroDefinitions = tabelize()
		stackOfMacroDefinitions:insert(macro)
		self.definitionsRoot:addOrReplace(macroName, macro)
		return
	end

	existingStackOfMacroDefinitions:remove(macro)
	existingStackOfMacroDefinitions:insert(macro)
end

function module:push(macro)
	assert.parameterTypeIsInstanceOf('macro', macro, AbstractMacroDefinition)

	local macroName = macro.name
	local existingStackOfMacroDefinitions = self.definitionsRoot:get(macroName)
	if existingStackOfMacroDefinitions == nil then
		local stackOfMacroDefinitions = tabelize()
		stackOfMacroDefinitions:insert(macro)
		self.definitionsRoot:addOrReplace(macroName, macro)
		return
	end

	existingStackOfMacroDefinitions:insert(macro)
end

function module:pop(macroName)
	assert.parameterTypeIsString('macroName', macroName)

	local existingStackOfMacroDefinitions = self.definitionsRoot:get(macroName)
	if existingStackOfMacroDefinitions == nil then
		return
	end

	local length = #existingStackOfMacroDefinitions
	if length == 1 then
		self.definitionsRoot:delete(macroName)
		return
	end

	existingStackOfMacroDefinitions:remove()
end

function module:undefine(macroName)
	assert.parameterTypeIsString('macroName', macroName)

	local existingStackOfMacroDefinitions = self.definitionsRoot:get(macroName)
	if existingStackOfMacroDefinitions == nil then
		return
	end

	self.definitionsRoot:delete(macroName)
end

function module:couldMatch(potentialPartialMacroName)
	if potentialPartialMacroName:match(self.macroNamePattern) == nil then
		return false
	end
	return self.definitionsRoot:matches(potentialPartialMacroName)
end

-- There's an issue with matching parameters
function module:get(macroName)
	local existingStackOfMacroDefinitions = self.definitionsRoot:get(macroName)
	if existingStackOfMacroDefinitions == nil then
		return nil
	end
	return existingStackOfMacroDefinitions[#existingStackOfMacroDefinitions]
end
