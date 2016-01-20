--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local OperatingSystem = halimede.build.toolchain.operatingSystems.OperatingSystem


local WindowsOperatingSystem = halimede.moduleclass('WindowsOperatingSystem', OperatingSystem)

-- Value of 'PROCESSOR_ARCHITECTURE' env variable
local architectures = createLookUpParseArchitectureFunction({
	x86 = 'IA-32',
	AMD64 = 'x86_64',
	IA64 = 'IA-64',
	EM64T = 'x86_64'
})

function module:initialize()
	OperatingSystem.initialize(self, nil, 'Windows NT', architectures, true, false, false)
	
	WindowsOperatingSystem.static.Windows = self
end

-- Do not register
function module:_registerUname(legacy, startsWith, exactlyMatches)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'match', 'split')
function module:_extractVersioningFromUname(sSwitchText, rSwitchText, vSwitchText)
	exception.throw('Should not be possible to extract versioning from uname')
end
