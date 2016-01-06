--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractMacroDefinition = require.sibling.AbstractMacroDefinition


halimede.moduleclass('UserMacroDefinition', AbstractMacroDefinition)

function module:initialize(name, isBuiltIn, ifIsBuiltInIsRecognisedOnlyWithParameters, numberOfArguments, expansion)
	assert.parameterTypeIsString('expansion', expansion)

	AbstractMacroDefinition.initialize(self, name, isBuiltIn, ifIsBuiltInIsRecognisedOnlyWithParameters, numberOfArguments)

	self.expansion = expansion
end

assert.globalTypeIsFunctionOrCall('ipairs', 'tostring', 'tonumber')
assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'gsub', 'sub')
function module:_execute(diversionBuffers, messages, warnMacroSequence, quotingRules, ...)

	local arguments = {...}
	local replacements = {
		['0'] = self.name,
		['#'] = #arguments
	}

	local asteriskValue = ''
	local atValue = ''
	for index, argument in ipairs(arguments) do
		replacements[tostring(index)] = argument
		if index > 1 then
			asteriskValue = asteriskValue .. ','
			atValue = atValue .. ','
		end
		asteriskValue = asteriskValue .. argument
		atValue = atValue .. quotingRules:quote(argument)
	end

	replacements['*'] = asteriskValue
	replacements['@'] = atValue

	if warnMacroSequence then
		if self.expansion:find('%${') then
			-- Not exactly the same text as GNU m4 1.4 (section 5.2)
			messages:warning("definition of `%s' contains sequence `${'", macroName)
		end
		if self.expansion:find('%$[%d%d]') then
			-- Not exactly the same text as GNU m4 1.4 (section 5.2)
			messages:warning("definition of `%s' contains sequence `$dd'", macroName)
		end
	end

	local argumentsReplaced = self.expansion:gsub('%$([%d#*@]+)', function(capture)
		local replacement = replacements[capture]
		if replacement ~= nil then
			return replacement
		end

		-- The above expression incorrectly captures $##, etc
		local index = tonumber(capture)
		if index == nil then
			return '$' .. capture
		end

		-- Things like '001' are also valid, bizarrely
		replacement = replacements[tostring(index)]
		if replacement ~= nil then
			return replacement
		end

		return ''
	end)

	return argumentsReplaced
end
