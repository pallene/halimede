--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local sibling = halimede.build.toolchain.platformPathStrategies
local AbstractPlatformPathStrategy = sibling.AbstractPlatformPathStrategy


halimede.moduleclass('LocalPlatformPathStrategy', AbstractPlatformPathStrategy)

function module:initialize()
	AbstractPlatformPathStrategy.initialize(self, true)
end

-- eg returns <destFolderShellPath>/bin if folderRelativePathElements == '{bin}'
assert.globalTypeIsFunctionOrCall('unpack')
function module:_path(prefixPath, destFolderShellPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
	return destFolderShellPath:appendFolders(unpack(folderRelativePathElements))
end
