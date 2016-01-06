--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local sibling = halimede.m4
local m4Assert = sibling.m4Assert
local Void = m4Assert.Void
local isVoid = m4Assert.isVoid
local isMissing = m4Assert.isMissing
local isMissingOrVoid = m4Assert.isMissingOrVoid


local Commenting = halimede.moduleclass('Commenting')

function module:initialize(beginCommentDelimiter, endCommentDelimiter)
	assert.parameterTypeIsString(beginCommentDelimiter)
	assert.parameterTypeIsString(endCommentDelimiter)

	self.beginCommentDelimiter = beginCommentDelimiter
	self.endCommentDelimiter = endCommentDelimiter
end

-- Comments recognized before macros
-- Should be called before sequenceMatchesBeginMacro
function module:prefixMatchesBeginComment(prefix)
	assert.parameterTypeIsString(prefix)

	return prefix == self.beginCommentDelimiter
end

function module:prefixMatchesEndComment(prefix)
	assert.parameterTypeIsString(prefix)

	return prefix == self.endCommentDelimiter
end

-- TODO: It is an error if the end of file occurs within a comment.
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'isEmpty')
local function builtin_changecom(start, end_)
	m4Assert.parameterTypeIsMissingOrIsVoidOrIsString(start)
	m4Assert.parameterTypeIsMissingOrIsVoidOrIsString(end_)

	local beginCommentDelimiter = "#"
	local endCommentDelimiter = "\n"
	if isMissing(start) then
		if isMissing(end_) then
			-- commenting is disabled
			beginCommentDelimiter = ""
			endCommentDelimiter = ""
		elseif isVoid(end_) then
			endCommentDelimiter = "\n"
		else
			endCommentDelimiter = "\n"
		end
	elseif isVoid(start) then
		-- commenting is disabled
		beginCommentDelimiter = ""
		endCommentDelimiter = ""
	else
		beginCommentDelimiter = start
		if isMissingOrVoid(end_) then
			endCommentDelimiter = "\n"
		else
			if not start:isEmpty() and end_:isEmpty() then
				endCommentDelimiter = "\n"
			end
			endCommentDelimiter = end_
		end
	end

	return Void
	--return Commenting:new(chosenStart, endCommentDelimiter)
end
