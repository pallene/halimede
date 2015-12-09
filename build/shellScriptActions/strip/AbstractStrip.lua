--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local ShellScript = halimede.io.shellScript.ShellScript


moduleclass('AbstractStrip')

function module:initialize(supportsLibraryStripping)
	assert.parameterTypeIsBoolean('supportsLibraryStripping', supportsLibraryStripping)
	
	self.supportsLibraryStripping = supportsLibraryStripping
end

function module:executable(shellScript, executableFilePathString)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)
	assert.parameterTypeIsString('executableFilePathString', executableFilePathString)
	
	shellScript:appendCommandLineToScript(self:_executable(executableFilePathString))
end

function module:library(shellScript, libraryFilePathString)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)
	assert.parameterTypeIsString('libraryFilePathString', libraryFilePathString)
	
	if self.supportsLibraryStripping then
		shellScript:appendCommandLineToScript(self:_library(libraryFilePathString))
	end
end

function module:_executable(executableFilePathString)
	exception.throw('Abstract Method')
end

function module:_library(libraryFilePathString)
	exception.throw('Abstract Method')
end
