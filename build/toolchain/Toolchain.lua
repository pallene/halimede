--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


moduleclass('Toolchain')

local halimede = require('halimede')
local assert = halimede.assert
local Platform = requireSibling('Platform')
local CompilerDriver = requireSibling('CompilerDriver')
local GnuTuple = requireSibling('GnuTuple')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')


function module:initialize(platform, sysrootPath)
	assert.parameterTypeIsInstanceOf(platform, Platform)
	assert.parameterTypeIsInstanceOf(sysrootPath, AbsolutePath)
	
	self.platform = platform
	self.sysrootPath = sysrootPath
end

function module:concatenateToPath(...)
	return self.platform:concatenateToPath(...)
end
