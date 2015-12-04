--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = halimede.io.paths.Path


-- eg returns '/opt/bin' if prefixPath == '/opt', perRecipeVersionRelativePathElements == {'package', 'version', 'dependencies'} and folderRelativePathElements == '{bin}'
assert.globalTypeIsFunction('unpack')
function module.constant(prefixPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
	assert.parameterTypeIsInstanceOf('prefixPath', prefixPath, Path)
	assert.parameterTypeIsTable('folderRelativePathElements', folderRelativePathElements)
	assert.parameterTypeIsTable('perRecipeVersionRelativePathElements', perRecipeVersionRelativePathElements)
	
	return prefixPath:appendFolders(unpack(folderRelativePathElements))
end
	
-- eg returns '/opt/bin/package/version/dependencies' if prefixPath == '/opt', perRecipeVersionRelativePathElements == {'package', 'version', 'dependencies'} and folderRelativePathElements == '{bin}'
assert.globalTypeIsFunction('unpack')
function module.versionAfter(prefixPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
	assert.parameterTypeIsInstanceOf('prefixPath', prefixPath, Path)
	assert.parameterTypeIsTable('folderRelativePathElements', folderRelativePathElements)
	assert.parameterTypeIsTable('perRecipeVersionRelativePathElements', perRecipeVersionRelativePathElements)
	
	return prefixPath:appendFolders(unpack(folderRelativePathElements)):appendFolders(unpack(perRecipeVersionRelativePathElements))
end

-- eg returns '/opt/package/version/dependencies/bin' if prefixPath == '/opt', perRecipeVersionRelativePathElements == {'package', 'version', 'dependencies'} and folderRelativePathElements == '{bin}'
function module.versionBefore(prefixPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
	assert.parameterTypeIsInstanceOf('prefixPath', prefixPath, Path)
	assert.parameterTypeIsTable('folderRelativePathElements', folderRelativePathElements)
	assert.parameterTypeIsTable('perRecipeVersionRelativePathElements', perRecipeVersionRelativePathElements)
	
	return prefixPath:appendFolders(unpack(perRecipeVersionRelativePathElements)):appendFolders(unpack(folderRelativePathElements))
end
