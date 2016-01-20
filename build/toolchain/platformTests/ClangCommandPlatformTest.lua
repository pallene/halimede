--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractCommandPlatformTest = halimede.build.toolchain.platformTests.AbstractCommandPlatformTest
local ShellLanguage = halimede.io.shellScript.ShellLanguage


halimede.moduleclass('GccCommandPlatformTest', AbstractCommandPlatformTest)

local validShellLanguages = {
	ShellLanguage.Posix
}

-- Path locations
function module:initialize()
	AbstractCommandPlatformTest.initialize(self, validShellLanguages, 'clang', '-v')
end

local lineStartsWith = 'Target: '
local lineStartsWithLength = #lineStartsWith
local remainderOfLineStartsAt = lineStartsWithLength + 1
assert.globalTypeIsFunctionOrCall('ipairs')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'split')
function module:_interpret(rawData)
	
	-- Look for a line that starts 'Target: TUPLE\n'
	local lines = rawData:split('\n')
	for _, line in ipairs(lines) do
		if line:sub(1, lineStartsWithLength) == lineStartsWith then
			return {
				gccTuple: line:sub(remainderOfLineStartsAt)
			}
		end
	end
	
	return false, "Could not find matching line"
end

