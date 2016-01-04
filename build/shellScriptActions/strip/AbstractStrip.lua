--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local ShellScript = halimede.io.shellScript.ShellScript
local AlreadyEscapedShellArgument = halimede.io.shellScript.AlreadyEscapedShellArgument


moduleclass('AbstractStrip')

function module:initialize(supportsLibraryStripping)
	assert.parameterTypeIsBoolean('supportsLibraryStripping', supportsLibraryStripping)
	
	self.supportsLibraryStripping = supportsLibraryStripping
end

function module:executable(shellScript, executableFilePathArgument)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)
	assert.parameterTypeIsInstanceOf('executableFilePathArgument', executableFilePathArgument, AlreadyEscapedShellArgument)
	
	shellScript:appendCommandLineToScript(self:_executable(executableFilePathArgument))
end

function module:library(shellScript, libraryFilePathArgument)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)
	assert.parameterTypeIsInstanceOf('libraryFilePathArgument', libraryFilePathArgument, AlreadyEscapedShellArgument)
	
	if self.supportsLibraryStripping then
		shellScript:appendCommandLineToScript(self:_library(libraryFilePathArgument))
	end
end

function module:_executable(executableFilePathArgument)
	exception.throw('Abstract Method')
end

function module:_library(libraryFilePathArgument)
	exception.throw('Abstract Method')
end
