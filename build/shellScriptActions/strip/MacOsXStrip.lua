--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractStrip = require.sibling('AbstractStrip')


moduleclass('MacOsXStrip', AbstractStrip)

function module:initialize()
	AbstractStrip.initialize(self, true)
end

function module:_executable(executableFilePathString)
	return 'strip', '-S', '-r', executableFilePathString
end

function module:_library(libraryFilePathString)
	return 'strip', '-S', executableFilePathString
end