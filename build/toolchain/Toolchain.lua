--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local Platform = requireSibling('Platform')
local CompilerDriver = requireSibling('CompilerDriver')
local GnuTuple = requireSibling('GnuTuple')
local tabelize = require('halimede.table.tabelize').tabelize


local Toolchain = class('Toolchain')

-- Maybe replace compilerDriver with a 'platform'
-- http://wiki.osdev.org/Target_Triplet
-- We use build for the build platform, and host platform for the platform compiled code will run on (host == target)
function Toochain:initialize(name, crossPlatform, buildPlatform)
	assert.parameterTypeIsString(name)
	assert.parameterTypeIsInstanceOf(crossPlatform, Platform)
	
	self.name = name
	self.crossPlatform = crossPlatform
	
	if buildPlatform == nil then
		self.buildPlatform = crossPlatform
		self.isCrossCompiling = false
	else
		assert.parameterTypeIsInstanceOf(buildPlatform, Platform)
		self.buildPlatform = buildPlatform
		self.isCrossCompiling = true
	end
	
	Toolchain.static[name] = self
end

Toolchain.static.addFileExtensionToFileNames = function(extensionWithLeadingPeriod, ...)
	local asTable
	if select('#', ...) == 1 then
		if type(...) == 'table' then
			asTable = select(1, ...)
		else
			asTable = {...}
		end
	else
		asTable = {...}
	end
	
	local result = tabelize()
	for _, basefilename in ipairs(asTable) do
		result:insert(basefilename .. extensionWithLeadingPeriod)
	end
	return result
end

function Toolchain:toCFiles(...)
	return Toolchain.addFileExtensionToFileNames('.c', ...)
end

-- TODO: not necessarily .cxx; several variants, sadly
function Toolchain:toCPlusPlusFiles(...)
	return Toolchain.addFileExtensionToFileNames('.cxx', ...)
end

Toolchain:new('Mac OS X Mavericks GCC / G++ 4.9 Homebrew', Platform['Mac OS X Mavericks GCC / G++ 4.9 Homebrew'])
Toolchain:new('Mac OS X Mavericks GCC / G++ 4.9 Homebrew', Platform['Mac OS X Yosemite GCC / G++ 4.9 Homebrew'])

return Toolchain
