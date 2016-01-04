--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local PathStyle = require.sibling.PathStyle
local exception = halimede.exception


local PathRelativity = moduleclass('PathRelativity')

-- isAbsoluteIncludingDeviceName: C:\path\to\file.txt (no POSIX equivalent unless using an empty device)
-- isRelativeToCurrentDeviceAndAbsoluteOnPosix: \path\to\file.txt or /path/to/file.txt
-- isRelativeToDeviceCurrentDirectoryOnCmd: C:file.txt
-- isRelative: path/to/file.txt
function module:initialize(name, isAbsoluteIncludingDeviceName, isRelativeToCurrentDeviceAndAbsoluteOnPosix, isRelativeToDeviceCurrentDirectoryOnCmd, isRelative)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsBoolean('isAbsoluteIncludingDeviceName', isAbsoluteIncludingDeviceName)
	assert.parameterTypeIsBoolean('isRelativeToCurrentDeviceAndAbsoluteOnPosix', isRelativeToCurrentDeviceAndAbsoluteOnPosix)
	assert.parameterTypeIsBoolean('isRelativeToDeviceCurrentDirectoryOnCmd', isRelativeToDeviceCurrentDirectoryOnCmd)
	assert.parameterTypeIsBoolean('isRelative', isRelative)
	
	self.name = name
	self.isAbsoluteIncludingDeviceName = isAbsoluteIncludingDeviceName
	self.isRelativeToCurrentDeviceAndAbsoluteOnPosix = isRelativeToCurrentDeviceAndAbsoluteOnPosix
	self.isRelativeToDeviceCurrentDirectoryOnCmd = isRelativeToDeviceCurrentDirectoryOnCmd
	self.isRelative = isRelative
	
	self.pathStyleFunctionName = 'toString' .. name
	self.isEffectivelyAbsolute = isAbsoluteIncludingDeviceName or isRelativeToCurrentDeviceAndAbsoluteOnPosix
	self.doesNotHaveARoot = isRelative or isRelativeToDeviceCurrentDirectoryOnCmd
	
	PathRelativity.static[name] = self
end

function module:guardDeviceIsPermitted(pathStyle, device)
	assert.parameterTypeIsInstanceOf('pathStyle', pathStyle, PathStyle)
	
	if device == nil then
		if self.isAbsoluteIncludingDeviceName or self.isRelativeToDeviceCurrentDirectoryOnCmd then
			exception.throw("device is required because the path relativity is '%s'", self.name)
		end
	else
		assert.parameterTypeIsString('device', device)
		if self.isRelativeToCurrentDeviceAndAbsoluteOnPosix or self.isRelative then
			exception.throw("A device '%s' is not permitted because the path relativity is '%s'", device, self.name)
		end
		if not pathStyle.hasDevices then
			exception.throw("A device '%s' is not permitted because the path style is '%s'", device, pathStyle.name)
		end
	end
end

function module:toString(pathStyle, pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)
	assert.parameterTypeIsInstanceOf('pathStyle', pathStyle, PathStyle)
	assert.parameterTypeIsTable('pathElements', pathElements)
	assert.parameterTypeIsBoolean('isFile', isFile)
	assert.parameterTypeIsBoolean('specifyCurrentDirectoryExplicitlyIfAppropriate', specifyCurrentDirectoryExplicitlyIfAppropriate)
	
	self:guardDeviceIsPermitted(pathStyle, device)
	return pathStyle[self.pathStyleFunctionName](pathStyle, pathElements, isFile, specifyCurrentDirectoryExplicitlyIfAppropriate, device)
end


PathRelativity:new('AbsoluteIncludingDeviceName', true, false, false, false)
PathRelativity:new('RelativeToCurrentDeviceAndAbsoluteOnPosix', false, true, false, false)
PathRelativity:new('RelativeToDeviceCurrentDirectoryOnCmd', false, false, true, false)
PathRelativity:new('Relative', false, false, false, true)
