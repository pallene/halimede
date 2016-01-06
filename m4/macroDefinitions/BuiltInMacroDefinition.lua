--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local sibling = halimede.m4.macroDefinitions
local AbstractMacroDefinition = sibling.AbstractMacroDefinition


halimede.moduleclass('BuiltInMacroDefinition', AbstractMacroDefinition)

function module:initialize(name, isBuiltIn, ifIsBuiltInIsRecognisedOnlyWithParameters, numberOfArguments, callback)
	assert.parameterTypeIsFunction('callback', callback)

	AbstractMacroDefinition.initialize(self, name, isBuiltIn, ifIsBuiltInIsRecognisedOnlyWithParameters, numberOfArguments)
end

assert.globalTypeIsFunctionOrCall('ipairs', 'tostring', 'tonumber')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gsub', 'sub')
function module:_execute(diversionBuffers, messages, warnMacroSequence, quotingRules, ...)
	return callback(diversionBuffers, messages, warnMacroSequence, quotingRules, ...)
end
