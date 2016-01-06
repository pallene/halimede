--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception


local QuotingRules = halimede.moduleclass('QuotingRules')

function module:initialize(beginQuoteDelimiter, endQuoteDelimiter)
	assert.parameterTypeIsString('beginQuoteDelimiter', beginQuoteDelimiter)
	assert.parameterTypeIsString('endQuoteDelimiter', endQuoteDelimiter)

	self.beginQuoteDelimiter = beginQuoteDelimiter
	self.endQuoteDelimiter = endQuoteDelimiter

	self.beginQuoteDelimiterLength = #beginQuoteDelimiter
end

function module:quote(argument)
	assert.parameterTypeIsString('argument', argument)

	return self.beginQuoteDelimiter .. argument .. self.endQuoteDelimiter
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'sub')
function module:couldBeStartOfQuotedString(prefix)
	assert.parameterTypeIsString('prefix', prefix)

	local prefixLength = #prefix
	local beginQuoteDelimiter = self.beginQuoteDelimiter
	local beginQuoteDelimiterLength = self.beginQuoteDelimiterLength

	if prefixLength == '' then
		exception.throw("Do not call this function with an empty prefix")
	end

	if prefixLength > beginQuoteDelimiterLength then
		return false
	end

	if prefixLength == beginQuoteDelimiterLength then
		return prefix == beginQuoteDelimiter
	end

	beginQuoteDelimiter:sub(1, prefixLength)
end




local sibling = halimede.m4
local m4Assert = sibling.m4Assert
local isVoid = m4Assert.isVoid
local isMissing = m4Assert.isMissing
local isMissingOrVoid = m4Assert.isMissingOrVoid

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
			if not start:isEmpty() and end_:isEmpty() then
				endQuoteDelimiter = "'"
			end
		end
	end

	return Quoting:new(chosenStart, endQuoteDelimiter)
end
