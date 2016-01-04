--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local exception = halimede.exception
local Trie = require.sibling.TrieElement


moduleclass('Trie')

function module:initialize()
	self.root = TrieElement:new('')
	self.index = {}
end

function module:find(name)
	assert.parameterTypeIsString('name', name)
	
	return self.index[name]
end

function module:get(name)
	return self.index[name]
end

-- returns boolean true if has it and was deleted
function module:delete(name)
	assert.parameterTypeIsString('name', name)
	
	local nameLength = #name
	local prefix = ''
	local prefixLength = 0
	
	if self.root:_isEmpty() then
		return false
	end
	
	self.index[name] = nil
	return self.root:_deleteUnguarded(name, nameLength, prefix, prefixNameLength)
end

-- returns boolean true if has a match
function module:matches(partialName)
	assert.parameterTypeIsString('partialName', partialName)
	
	local partialNameLength = #partialName
	local prefix = ''
	local prefixLength = 0
	
	if self:get(name) ~= nil then
		return true
	end
	
	return self.root:_matchesUnguarded(partialName, partialNameLength, prefix, prefixNameLength)
end

-- returns previous element, boolean true if added
function module:addOrReplace(name, element)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsNotNil('element', element)
	
	local nameLength = #name
	local prefix = ''
	local prefixLength = 0
	
	self.index[name] = element
	return self.root:_addOrReplaceUnguarded(name, element, nameLength, prefix, prefixLength)
end
