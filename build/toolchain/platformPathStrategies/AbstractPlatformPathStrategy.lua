--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local Path = halimede.io.paths.Path
local ShellPath = halimede.io.shellScript.ShellPath


halimede.moduleclass('AbstractPlatformPathStrategy')

function module:initialize(destinationIsInstallation)
	assert.parameterTypeIsBoolean('destinationIsInstallation', destinationIsInstallation)
	
	self.destinationIsInstallation = destinationIsInstallation
end

function module:path(prefixPath, destFolderShellPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
	assert.parameterTypeIsInstanceOf('prefixPath', prefixPath, Path)
	assert.parameterTypeIsInstanceOf('destFolderShellPath', destFolderShellPath, ShellPath)
	assert.parameterTypeIsTable('folderRelativePathElements', folderRelativePathElements)
	assert.parameterTypeIsTable('perRecipeVersionRelativePathElements', perRecipeVersionRelativePathElements)
	
	return self:_path(prefixPath, destFolderShellPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
end

function module:_path(prefixPath, destFolderShellPath, folderRelativePathElements, perRecipeVersionRelativePathElements)
	exception.throw('Abstract Method')
end
