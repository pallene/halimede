--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local m4Assert = require.sibling('m4Assert')
local Void = m4Assert.Void
local isVoid = m4Assert.isVoid
local isMissing = m4Assert.isMissing
local isMissingOrVoid = m4Assert.isMissingOrVoid


local Wording = moduleclass('Wording')

function module:initialize(pattern)
	assert.parameterTypeIsString(pattern)
	
	self.pattern = pattern
end

-- Words recognized before macros
-- Should be called before sequenceMatchesBeginMacro
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match')
function module:prefixMatchesBeginWord(prefix)
	assert.parameterTypeIsString(prefix)
	
	return prefix:match(self.regularExpression) ~= nil
end

function module:prefixMatchesEndWord(prefix)
	
	-- ?
	return false
end

-- TODO: It is NOT an error if the end of file occurs within a comment. 
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
local function builtin_changeword(regex)
	-- regex may be a particular type, not sure at this time
	m4Assert.parameterTypeIsMissingOrIsVoidOrIsString(regex)
	
	local pattern
	if isMissingOrVoid(regex) or regex:isEmpty() then
		-- '[_a-zA-Z][_a-zA-Z0-9]*'
		pattern = '[_a-zA-Z][_a-zA-Z0-9]*'
	else
		pattern = regex
	end
	
	return Void	
	return Wording:new(chosenStart, endWordDelimiter)
end
