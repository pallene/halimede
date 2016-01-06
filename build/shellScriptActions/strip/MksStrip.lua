--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local sibling = halimede.build.shellScriptActions.strip
local AbstractStrip = sibling.AbstractStrip


halimede.moduleclass('MksStrip', AbstractStrip)

function module:initialize()
	AbstractStrip.initialize(self, false)
end

function module:_executable(executableFilePathArgument)
	assert.parameterTypeIsString('executableFilePathArgument', executableFilePathArgument)

	return 'strip', '-m', executableFilePathArgument
end
