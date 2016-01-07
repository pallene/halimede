--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local sibling = halimede.build.shellScriptActions.strip
local AbstractStrip = sibling.AbstractStrip
local ShellArgument = halimede.io.shellScript.ShellArgument


halimede.moduleclass('GnuStrip', AbstractStrip)

local escapedArgument_strip = ShellArgument:new('strip')
local escapedArgument_preservedates= ShellArgument:new('--preserve-dates')
local escapedArgument_enabledeterministicarchives = ShellArgument:new('--enable-deterministic-archives')
local escapedArgument_stripdebug = ShellArgument:new('--strip-debug')
local escapedArgument_stripunneeded = ShellArgument:new('--strip-unneeded')

function module:initialize()
	AbstractStrip.initialize(self, true)
end

function module:_executable(executableFilePathArgument)
	return escapedArgument_strip, escapedArgument_preservedates, escapedArgument_enabledeterministicarchives, escapedArgument_stripdebug, escapedArgument_stripunneeded, executableFilePathArgument
end

function module:_library(libraryFilePathArgument)
	return escapedArgument_strip, escapedArgument_preservedates, escapedArgument_enabledeterministicarchives, escapedArgument_stripdebug, libraryFilePathArgument
end
