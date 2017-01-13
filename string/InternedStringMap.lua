--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local type = halimede.type
local table = halimede.table


halimede.moduleclass('InternedStringMap')

function module:initialize(...)
	local numberOfArguments = select('#', ...)
	
	if numberOfArguments == 0 then
		self.internedStrings = {}
	elseif numberOfArguments > 1 then
		self.internedStrings = {}
		for index, potentialString in ipairs({...}) do
			if type.isNotString(potentialString) then
				exception.throw("Only strings are permissible if more than one argument is supplied, argument (one-based) '%s'' is of type ''", index, type(potentialString))
			end
			if self.internedString[potentialString] ~= nil then
				exception.throw("String argument (one-based) '%s'' is a duplicate", index)
			end
			self.internedStrings[potentialString] = potentialString
		end
	else
		local first = select(1, ...)
		if type.isString(first) then
			self.internedString = {
				[first] = first
			}
		elseif type.isTable(first) then
			self.internedString = halimede.table.shallowCopy(first)
		else
			exception.throw('Only a table or string is permissible if one argument is supplied')
		end
	end
end

function module:__tostring()
	return ('%s(%s)'):format(self.class.name, #self.internedStrings)
end

-- string interning replaces multiple copies (and so references) of the same string value with one reference, so saving a lot of memory space on large documents with lots of namespaceUris and simpleNames that are repeated
function module:internStringAndRetrieveInternedString(stringToIntern, defaultIfStringToInternIsNil)
	if stringToIntern == nil then
		if defaultIfStringToInternIsNil == nil then
			exception.throw('Default is nil and stringToIntern is nil')
		end
		stringToIntern = defaultIfStringToInternIsNil
	end
	
	local extantInternedStringIfAny = self.internedStrings[stringToIntern]
	if extantInternedStringIfAny ~= nil then
		return extantInternedStringIfAny
	end
	
	self.internedStrings[stringToIntern] = stringToIntern
	
	return stringToIntern
end

function module:normalizeAndInternNamespaceUri(potentiallyNilNamespaceUri)
	assert.parameterTypeIsStringOrNil('potentiallyNilUninternedNamespaceUri', potentiallyNilUninternedNamespaceUri)
	
	local namespaceUri
	if potentiallyNilNamespaceUri == nil then
		return xmldom.NoNamespaceUri
	else
		return self.internString(potentiallyNilNamespaceUri)
	end
end
