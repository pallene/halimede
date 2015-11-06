--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('ToolchainPaths')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')

local halimede = require('halimede')
local assert = halimede.assert
local exception = require('halimede.exception')


function module:initialize(sysrootPath)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	
	self.sysrootPath = sysrootPath
end
