--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPath = requireSibling('AbstractPath')
local RelativePath = moduleclass('RelativePath', AbstractPath)

local halimede = require('halimede')
local assert = halimede.assert
local tabelize = require('halimede.table.tabelize').tabelize
local shallowCopy = require('halimede.table.shallowCopy').shallowCopy


function RelativePath:initialize(folderSeparator, ...)
	AbstractPath.initialize(self, folderSeparator, true, '', ...)
end

function RelativePath:_appendSubFolders(childFoldersTable)
	
	local folders = tabelize(shallowCopy(self.folders))
	for _, childFolder in ipairs(childFoldersTable) do
		folders:insert(childFolder)
	end

	return RelativePath:new(self.folderSeparator, unpack(folders))
end
