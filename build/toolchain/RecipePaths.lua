--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Platform = require.sibling.Platform
local PlatformPaths = require.sibling.PlatformPaths


moduleclass('RecipePaths')

function module:initialize(platform, platformPaths, versionRelativePathElements)
	assert.parameterTypeIsInstanceOf('platform', platform, Platform)
	assert.parameterTypeIsInstanceOf('platformPaths', platformPaths, PlatformPaths)
	assert.parameterTypeIsTable('versionRelativePathElements', versionRelativePathElements)
	
	self.platform = platform
	self.platformPaths = platformPaths
	self.versionRelativePathElements = versionRelativePathElements
end

function module:path(pathName)
	assert.parameterTypeIsString('pathName', pathName)
	
	return self.platformPaths[pathName](self.platformPaths, self.versionRelativePathElements)
end
