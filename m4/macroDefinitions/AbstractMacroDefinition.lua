--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local exception = halimede.exception


moduleclass('AbstractMacroDefinition')

function module:initialize(name, isBuiltIn, ifIsBuiltInIsRecognisedOnlyWithParameters, numberOfArguments)
	assert.parameterTypeIsString('name', name)
	assert.parameterTypeIsBoolean('isBuiltIn', isBuiltIn)
	assert.parameterTypeIsBoolean('ifIsBuiltInIsRecognisedOnlyWithParameters', ifIsBuiltInIsRecognisedOnlyWithParameters)
	assert.parameterTypeIsPositiveInteger('numberOfArguments', numberOfArguments)
	
	self.name = name
	self.isBuiltIn = isBuiltIn
	self.ifIsBuiltInIsRecognisedOnlyWithParameters = ifIsBuiltInIsRecognisedOnlyWithParameters
	self.numberOfArguments = numberOfArguments
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'format')
function module:__tostring()
	return ("%s(%s, %s, $s)"):format(self.class.name, self.isBuiltIn, self.name, self.numberOfArguments)
end

-- The defn() macro has a special result kind; there is also Void()
-- missing arguments (ie too few) are defined as empty string
-- but there is an exception for builtins
-- excess arguments are ignored
-- messages issued if too few / too many
-- whitespace is SP, TAB, LF CR VT FF
-- leading whitespace is stripped BEFORE macro expansion of arguments. Trailing whitespace is preserved

-- It is possible for a macro’s definition to change during argument collection, in which case the expansion uses the definition that was in effect at the time the opening ‘(’ was seen. 
assert.globalTypeIsFunctionOrCall('unpack')
function module:execute(diversionBuffers, messages, warnMacroSequence, quotingRules, ...)
	assert.parameterTypeIsInstanceOf('diversionBuffers', diversionBuffers, DiversionBuffers)
	assert.parameterTypeIsInstanceOf('messages', messages, Messages)
	assert.parameterTypeIsBoolean('warnMacroSequence', warnMacroSequence)
	assert.parameterTypeIsInstanceOf('quotingRules', quotingRules, QuotingRules)
	
	local arguments = {...}
	local numberOfArguments = #arguments
	if self.isBuiltIn and numberOfArguments ~= self.numberOfArguments then
		if numberOfArguments < self.numberOfArguments then
			messages.warning("too few arguments to builtin `%s'", self.name)
		else
			messages.warning("execess arguments to builtin `%s' ignored", self.name)
		end
	end
	
	local numberOfArgumentsToFillWithEmptyString = self.numberOfArguments - numberOfArguments
	while numberOfArgumentsToFillWithEmptyString > 0 do
		arguments[numberOfArguments + numberOfArgumentsToFillWithEmptyString] = ''
		
		numberOfArgumentsToFillWithEmptyString = numberOfArgumentsToFillWithEmptyString - 1
	end
	
	local truncatedCopyOfArguments = {}
	local argumentIndexToCopy = 1
	while argumentIndexToCopy <= self.numberOfArguments do
		truncatedCopyOfArguments[argumentIndexToCopy] = arguments[argumentIndexToCopy]
		argumentIndexToCopy = argumentIndexToCopy + 1
	end
	
	return rescan(self:_execute(diversionBuffers, messages, warnMacroSequence, quotingRules, self.name, unpack(truncatedCopyOfArguments)))
end
