--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local class = require('middleclass')
local AbstractPath = requireSibling('AbstractPath')
local halimede = require('halimede')
local assert = halimede.assert


local AbsolutePath = class('AbsolutePath', AbstractPath)

local function initialPathPrefix(driveOrUncPrefixIfWindows)
	local folderSeparator = AbstractClass.folderSeparator
	
	local drivePrefix
	if folderSeparator == '\\' then
		drivePrefix = driveOrUncPrefixIfWindows
	else
		drivePrefix = ''
	end
	
	return drivePrefix .. folderSeparator
end

-- eg C:\temp => absolutePath('C:', 'temp')
-- eg \\server\admin$\system32 => absolutePath('\\server\admin$', 'system32') [admin$ is usually C:\WINDOWS or C:\WINNT]
-- eg \\server\temp (C:\temp, probably) => absolutePath('\\server', 'temp')
-- eg /usr/bin => absolutePath('', 'usr', 'bin')
function AbsolutePath:initialize(driveOrUncPrefixIfWindows, ...)
	assert.parameterTypeIsString(driveOrUncPrefixIfWindows)
	
	AbstractPath.initialize(self, false, initialPathPrefix(driveOrUncPrefixIfWindows), ...)
	
	self.driveOrUncPrefixIfWindows = driveOrUncPrefixIfWindows
end

function AbsolutePath:_construct(...)
	return AbsolutePath:new(self.driveOrUncPrefixIfWindows, ...)
end

return AbsolutePath
