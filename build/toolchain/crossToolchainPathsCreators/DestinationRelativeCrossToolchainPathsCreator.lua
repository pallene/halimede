--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local ExecutionEnvironment = halimede.build.toolchain.ExecutionEnvironment
local ToolchainPaths = halimede.build.toolchain.ToolchainPaths
local AbstractCrossToolchainPathsCreator = require.sibling('AbstractCrossToolchainPathsCreator')


moduleclass('DestinationRelativeCrossToolchainPathsCreator', AbstractCrossToolchainPathsCreator)

function module:initialize()
	AbstractCrossToolchainPathsCreator.initialize(self)
end

function module:create(executionEnvironment, versionRelativePath)
	assert.parameterTypeIsInstanceOf('executionEnvironment', executionEnvironment, ExecutionEnvironment)
	
	local sysrootPath = executionEnvironment.destinationPath
	local prefixPath = sysrootPath:appendFolders('opt', 'prefix')  -- Mounted noexec, nosuid
	local execPrefixPath = sysrootPath:appendFolders('opt', 'exec-prefix')  -- Mounted exec, nosuid
	local libPrefixPath = sysrootPath:appendFolders('opt', 'lib-prefix')  -- Might be mounted exec, ideally noexec and nosuid
	
	return ToolchainPaths:new(sysrootPath, versionRelativePath, prefixPath, execPrefixPath, libPrefixPath)
end
