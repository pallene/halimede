--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


module.Path = require('halimede.io.paths.Path'),
module.Paths = require('halimede.io.paths.Paths'),
module.PathStyle = require('halimede.io.paths.PathStyle'),
module.PathRelativity = require('halimede.io.paths.PathRelativity'),
module.CStandard = require('halimede.build.toolchain.CStandard'),
module.LegacyCandCPlusPlusStringLiteralEncoding = require('halimede.build.toolchain.LegacyCandCPlusPlusStringLiteralEncoding'),
module.CommandLineDefines = require('halimede.build.defines.CommandLineDefines'),
module._FILE_OFFSET_BITS = require('halimede.build.defines._FILE_OFFSET_BITS'),
module.CRAY_STACKSEG_END = require('halimede.build.defines.CRAY_STACKSEG_END'),
module.RETSIGTYPE = require('halimede.build.defines.RETSIGTYPE'),
module.ST_MTIM_NSEC = require('halimede.build.defines.ST_MTIM_NSEC'),
module.STACK_DIRECTION = require('halimede.build.defines.STACK_DIRECTION')
