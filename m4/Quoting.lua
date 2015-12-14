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


local Quoting = moduleclass('Quoting')

function module:initialize(beginQuoteDelimiter, endQuoteDelimiter)
	assert.parameterTypeIsString(beginQuoteDelimiter)
	assert.parameterTypeIsString(endQuoteDelimiter)
	
	self.beginQuoteDelimiter = beginQuoteDelimiter
	self.endQuoteDelimiter = endQuoteDelimiter
end

-- Should be called after sequenceMatchesBeginMacro
function module:prefixMatchesBeginQuote(prefix)
	assert.parameterTypeIsString(prefix)
	
	return prefix == self.beginQuoteDelimiter
end

function module:prefixMatchesEndQuote(prefix)
	assert.parameterTypeIsString(prefix)
	
	return prefix == self.endQuoteDelimiter
end

-- TODO: It is an error if the end of file occurs within a quoted string. 
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
local function builtin_changequote(start, end_)
	m4Assert.parameterTypeIsMissingOrIsVoidOrIsString(start)
	m4Assert.parameterTypeIsMissingOrIsVoidOrIsString(end_)
	
	local beginQuoteDelimiter = "`"
	local endQuoteDelimiter = "'"
	if isMissing(start) then
		beginQuoteDelimiter = "`"
		if isMissing(end_) then
			endQuoteDelimiter = "'"
		elseif isVoid(end_) then
			endQuoteDelimiter = "'"
		else
			endQuoteDelimiter = "'"
		end
	elseif isVoid(start) then
		-- quoting is disabled
		beginQuoteDelimiter = ""
		endQuoteDelimiter = ""
	else
		beginQuoteDelimiter = start
		if isMissingOrVoid(end_) then
			endQuoteDelimiter = "'"
		else
			if not start:isEmpty() and end:isEmpty() then
				endQuoteDelimiter = "'"
			end
		end
	end
	
	return Void
	return Quoting:new(chosenStart, endQuoteDelimiter)
end
