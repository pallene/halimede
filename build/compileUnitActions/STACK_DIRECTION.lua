--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local numberEnumerationClass = require('halimede.enumeration').numberEnumerationClass


-- STACK_DIRECTION > 0 => grows toward higher addresses
-- STACK_DIRECTION < 0 => grows toward lower addresses
-- STACK_DIRECTION = 0 => direction of growth unknown
return numberEnumerationClass('STACK_DIRECTION', 
	{'StackGrowsTowardsHigherAddresses', 1},
	{'StackGrowsTowardsLowerAddresses', -1},
	{'StackGrowthDirectionIsUnknown', 0}
)
