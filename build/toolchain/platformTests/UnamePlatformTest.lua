--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractCommandPlatformTest = halimede.build.toolchain.platformTests.AbstractCommandPlatformTest
local fromUname = halimede.build.toolchain.OperatingSystem.fromUname


halimede.moduleclass('UnamePlatformTest')

-- affected by LANG, LC_ALL, LC_CTYPE, LC_MESSAGES, NLSPATH; we need a clean-environment approach
function module:initialize()
end

assert.globalTypeIsFunctionOrCall('unpack', 'pcall')
function module:executeTest()
	local ok, sSwitchText = AbstractCommandPlatformTest.executeComand('uname', '-s')
	if not ok then
		return false, sSwitchText
	end
	
	local operatingSystem, errorMessageOrNil = fromUname(sSwitchText)
	if operatingSystem == nil then
		return false, errorMessageOrNil
	end
	
	local ok, mSwitchText = AbstractCommandPlatformTest.executeComand('uname', '-m')
	if not ok then
		return false, mSwitchText
	end
	
	local ok, vSwitchText = AbstractCommandPlatformTest.executeComand('uname', '-v')
	if not ok then
		return false, 'Could not find uname -v'
	end
	
	-- Not supported by Tandem NonStop AFAIK
	local ok, rSwitchText = AbstractCommandPlatformTest.executeComand('uname', '-r')
	if not ok then
		rSwitchText = nil
	end
	
	return operatingSystem:extractVersioningFromUname(mSwitchText, rSwitchText, vSwitchText)
end
