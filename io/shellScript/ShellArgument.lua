--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')


local ShellArgument = halimede.moduleclass('ShellArgument')

function module:initialize(argument)
	assert.parameterTypeIsString('argument', argument)

	self.argument = argument
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('table', 'insert')
function module:insertValue(someTable)
	assert.parameterTypeIsTable('someTable', someTable)

	table.insert(someTable, self.argument)
	return someTable
end

function module:prepend(text)
	assert.parameterTypeIsString('text', text)

	return ShellArgument:new(text .. self.argument)
end
