--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local stringEnumerationClass = require('halimede.enumeration').stringEnumerationClass


-- Some of these names will need translation to work on older GNU versions, eg c99 => c9x
-- Accurate for gcc-4.9
local CStandard = stringEnumerationClass('CStandard', 
	'c89',             -- equivalent to -ansi for C Code
	'iso9899:199409',
	'c99',
	'c11',
	'gnu89',
	'gnu99',
	'gnu11',
	'c++98',           -- equivalent to -ansi for C++ Code
	'gnu++98',
	'c++11',
	'gnu++11',
	'c++1y',           -- experimental
	'gnu++1y',         -- experimental
)

-- Aliases
CStandard.static['iso9899:1990'] = CStandard.static.c89
CStandard.static['c90'] = CStandard.static.c89
CStandard.static['iso9899:1999'] = CStandard.static.c99
CStandard.static['iso9899:2011'] = CStandard.static.c11
CStandard.static['gnu90'] = CStandard.static.gnu89
CStandard.static['c++03'] = CStandard.static['c++98']
CStandard.static['gnu++03'] = CStandard.static['gnu++98']


-- Deprecated Aliases
CStandard.static['c9x'] = CStandard.static.c9x
CStandard.static['iso9899:199x'] = CStandard.static.c99
CStandard.static['c1x'] = CStandard.static.c11
CStandard.static['gnu9x'] = CStandard.static.gnu99
CStandard.static['gnu1x'] = CStandard.static.gnu11
CStandard.static['c++0x'] = CStandard.static['c++11']
CStandard.static['gnu++0x'] = CStandard.static['gnu++11']

return CStandard
