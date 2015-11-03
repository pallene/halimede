--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize
local class = require('halimede.middleclass')
local Toolchain = requireSibling('Toolchain')


local BuildEnvironment = class('BuildEnvironment')

function BuildEnvironment(buildToolchain, crossToolchain)
	self.buildToolchain = crossToolchain
	
	if buildToolchain == nil then
		self.buildToolchain = crossToolchain
		self.isCrossCompiling = false
	else
		assert.parameterTypeIsInstanceOf(buildToolchain, Toolchain)
		
		self.buildToolchain = buildToolchain
		
		local isCrossCompiling
		if buildToolchain == crossToolchain then
			isCrossCompiling = false
		else
			isCrossCompiling = true
		end
		self.isCrossCompiling = isCrossCompiling
	end
end

assert.globalTypeIsFunction('select', 'type', 'ipairs')
BuildEnvironment.static.addFileExtensionToFileNames = function(extensionWithLeadingPeriod, ...)
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

function BuildEnvironment:toCFiles(...)
	return BuildEnvironment.addFileExtensionToFileNames('.c', ...)
end

-- TODO: not necessarily .cxx; several variants, sadly
function BuildEnvironment:toCPlusPlusFiles(...)
	return BuildEnvironment.addFileExtensionToFileNames('.cxx', ...)
end

return BuildEnvironment
