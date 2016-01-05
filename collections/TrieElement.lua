--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')


local TrieElement = halimede.moduleclass('TrieElement')

module.static.newTrieRoot = function()
	return Trie:new('')
end

function module:initialize(prefix)
	assert.parameterTypeIsString('prefix', prefix)

	self.prefix = prefix
	self.element = nil

	self.prefixLength = #prefix
	self.trieChildren = {}
end

function module:_isEmpty()
	return self.element == nil and #self.trieChildren == 0
end

function module:_deleteUnguarded(name, nameLength, prefix, prefixNameLength)
	if nameLength == prefixLength then
		self.element = nil
		return true
	end

	local trieChild, trieCharacter = self:_potentiallyNilTrieChild(partialName, prefixLength)
	if trieChild == nil then
		return false
	end

	local deleted = trieChild:_deleteUnguarded(name, nameLength, trieChild.prefix, prefixNameLength + 1)
	if deleted and trieChild:_isEmpty() then
		self.trieChildren[trieCharacter] = nil
	end
	return deleted
end

function module:_matchesUnguarded(partialName, partialNameLength, prefix, prefixNameLength)
	if partialNameLength == prefixLength then
		return true
	end

	local trieChild, _ = self:_potentiallyNilTrieChild(partialName, prefixLength)
	if trieChild == nil then
		return false
	end

	return trieChild:_matchesUnguarded(partialName, partialNameLength, trieChild.prefix, prefixNameLength + 1)
end

function module:_addOrReplaceUnguarded(name, element, nameLength, prefix, prefixLength)
	if nameLength == prefixLength then
		local originalElement = self.element
		self.element = element
		return originalElement, originalElement == nil
	end

	return self:_trieChildAddOrReplaceUnguarded(name, element, nameLength, prefix, prefixLength)
end

function module:_trieChildAddOrReplaceUnguarded(name, element, nameLength, prefix, prefixLength)
	local trieChild = self:_trieChild(name, prefix, prefixLength)
	return trieChild:_addOrReplaceUnguarded(name, element, nameLength, trieChild.prefix, prefixLength + 1)
end

function module:_trieChild(name, prefix, prefixLength)
	local trieChild, trieCharacter = self:_potentiallyNilTrieChild(name, prefixLength)

	if trieChild == nil then
		trieChild = TrieElement:new(prefix .. trieCharacter)
		self.trieChildren[trieCharacter] = trieChild
	end
	return trieChild
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'sub')
function module:_potentiallyNilTrieChild(name, prefixLength)
	local trieCharacterIndex = prefixLength + 1
	local trieCharacter = name:sub(trieCharacterIndex, trieCharacterIndex)
	return self.trieChildren[trieCharacter], trieCharacter
end
