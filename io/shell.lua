--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = require('halimede.exception')
local read = requireSibling('read')
local assert = require('halimede.assert')

assert.globalTableHasChieldFieldOfTypeFunction('io', 'popen')
local function openShellCommand(mode, shellLanguage, ...)
	local command = shellLanguage.toShellCommand(...)
	local fileHandle = io.popen(command, mode)
	if fileHandle == nil then
		exception.throw('Could not open shell for command "%s"', command)
	end
	return fileHandle
end

function module.openShellCommandReadingStandardIn(shellLanguage, ...)
	return openShellCommand('r', shellLanguage, ...)
end
local openShellCommandReadingStandardIn = module.openShellCommandReadingStandardIn

function module.openShellCommandWritingStandardOut(shellLanguage, ...)
	return openShellCommand('w', shellLanguage, ...)
end
local openShellCommandWritingStandardOut = module.openShellCommandWritingStandardOut

function module.executeInShellAndReadAllFromStandardIn(shellLanguage, ...)
	local fileHandle = openShellCommandReadingStandardIn(shellLanguage, ...)
	return read.allContentsInTextModeFromFileHandleAndClose(fileHandle)
end
