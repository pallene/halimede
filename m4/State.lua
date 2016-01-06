--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local Messages = require.sibling.Messages
local QuotingRules = require.sibling.Messages
local DiversionBuffers = require.sibling.DiversionBuffers


halimede.moduleclass('State')

function module:initialize(lineDelimiter, isQuiet, warningFileHandleStream, debugFileHandleStream)

	self.currentLineNumber = 0  -- gotchas for m4wrap
	self.currentFilePath = 'stdin'
	self.currentProgram = '/path/to/m4' -- Actually, should be fully qualified path to current executable

	self.messages = Messages:new(lineDelimiter, isQuiet, warningFileHandleStream, debugFileHandleStream)
	self.quotingRules = QuotingRules:new("`", "'")
	self.diversionBuffers = DiversionBuffers:new()
	self.lastShellCommandExitStatus = 0

	-- Possibly immutable
	self.warnMacroSequence = false

end
