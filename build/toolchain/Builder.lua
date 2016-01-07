--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local ShellScript = halimede.io.shellScript.ShellScript
local ShellPath = halimede.io.shellScript.ShellPath
local Actions = halimede.build.toolchain.Actions
local Platform = halimede.build.toolchain.Platform
local RecipePaths = halimede.build.toolchain.RecipePaths
local AbstractStrip = halimede.build.shellScriptActions.strip.AbstractStrip
local ConfigHDefines = halimede.build.defines.ConfigHDefines


halimede.delegateclass('Builder', 'actions')

local defaultShellScriptActionsNamespace = 'halimede.build.shellScriptActions'
function module:initialize(shellScript, dependencies, buildVariant, sourceFolderShellPath, patchFolderShellPath, buildFolderShellPath, destFolderShellPath, buildPlatform, buildRecipePaths, crossPlatform, crossRecipePaths, arguments, strip, configHDefines)
	assert.parameterTypeIsInstanceOf('shellScript', shellScript, ShellScript)
	assert.parameterTypeIsTable('dependencies', dependencies)
	assert.parameterTypeIsTable('buildVariant', buildVariant)
	assert.parameterTypeIsInstanceOf('sourceFolderShellPath', sourceFolderShellPath, ShellPath)
	assert.parameterTypeIsInstanceOf('patchFolderShellPath', patchFolderShellPath, ShellPath)
	assert.parameterTypeIsInstanceOf('buildFolderShellPath', buildFolderShellPath, ShellPath)
	assert.parameterTypeIsInstanceOf('destFolderShellPath', destFolderShellPath, ShellPath)
	assert.parameterTypeIsInstanceOf('buildPlatform', buildPlatform, Platform)
	assert.parameterTypeIsInstanceOf('buildRecipePaths', buildRecipePaths, RecipePaths)
	assert.parameterTypeIsInstanceOf('crossPlatform', crossPlatform, Platform)
	assert.parameterTypeIsInstanceOf('crossRecipePaths', crossRecipePaths, RecipePaths)
	assert.parameterTypeIsTable('arguments', arguments)
	assert.parameterTypeIsInstanceOf('strip', strip, AbstractStrip)
	assert.parameterTypeIsInstanceOf('configHDefines', configHDefines, ConfigHDefines)

	self.sourceFolderShellPath = sourceFolderShellPath
	self.patchFolderShellPath = patchFolderShellPath
	self.buildFolderShellPath = buildFolderShellPath
	self.destFolderShellPath = destFolderShellPath
	self.buildPlatform = buildPlatform
	self.buildRecipePaths = buildRecipePaths
	self.crossPlatform = crossPlatform
	self.crossRecipePaths = crossRecipePaths
	self.arguments = arguments
	self.strip = strip
	self.configHDefines = configHDefines

	local actions = Actions:new(shellScript, self, dependencies, buildVariant, defaultShellScriptActionsNamespace)
	Actions.appendCompositeActionRecreateFolderPath(actions)
	self.actions = actions

	self.binCross = crossRecipePaths:path(destFolderShellPath, 'bin')
	self.sbinCross = crossRecipePaths:path(destFolderShellPath, 'sbin')
	self.libexecCross = crossRecipePaths:path(destFolderShellPath, 'libexec')
	self.etcCross = crossRecipePaths:path(destFolderShellPath, 'etc')
	self.comCross = crossRecipePaths:path(destFolderShellPath, 'com')
	self.varCross = crossRecipePaths:path(destFolderShellPath, 'var')
	self.libCross = crossRecipePaths:path(destFolderShellPath, 'lib')
	self.includeCross = crossRecipePaths:path(destFolderShellPath, 'include')
	self.oldincludeCross = crossRecipePaths:path(destFolderShellPath, 'oldinclude')
	self.shareCross = crossRecipePaths:path(destFolderShellPath, 'share')
	self.dataCross = crossRecipePaths:path(destFolderShellPath, 'data')
	self.infoCross = crossRecipePaths:path(destFolderShellPath, 'info')
	self.localeCross = crossRecipePaths:path(destFolderShellPath, 'locale')
	self.manCross = crossRecipePaths:path(destFolderShellPath, 'man')
	self.docCross = crossRecipePaths:path(destFolderShellPath, 'doc')
	self.htmlCross = crossRecipePaths:path(destFolderShellPath, 'html')
	self.dviCross = crossRecipePaths:path(destFolderShellPath, 'dvi')
	self.docCross = crossRecipePaths:path(destFolderShellPath, 'doc')
	self.psCross = crossRecipePaths:path(destFolderShellPath, 'ps')
	
	self.binBuild = buildRecipePaths:path(destFolderShellPath, 'bin')
	self.sbinBuild = buildRecipePaths:path(destFolderShellPath, 'sbin')
	self.libexecBuild = buildRecipePaths:path(destFolderShellPath, 'libexec')
	self.etcBuild = buildRecipePaths:path(destFolderShellPath, 'etc')
	self.comBuild = buildRecipePaths:path(destFolderShellPath, 'com')
	self.varBuild = buildRecipePaths:path(destFolderShellPath, 'var')
	self.libBuild = buildRecipePaths:path(destFolderShellPath, 'lib')
	self.includeBuild = buildRecipePaths:path(destFolderShellPath, 'include')
	self.oldincludeBuild = buildRecipePaths:path(destFolderShellPath, 'oldinclude')
	self.shareBuild = buildRecipePaths:path(destFolderShellPath, 'share')
	self.dataBuild = buildRecipePaths:path(destFolderShellPath, 'data')
	self.infoBuild = buildRecipePaths:path(destFolderShellPath, 'info')
	self.localeBuild = buildRecipePaths:path(destFolderShellPath, 'locale')
	self.manBuild = buildRecipePaths:path(destFolderShellPath, 'man')
	self.docBuild = buildRecipePaths:path(destFolderShellPath, 'doc')
	self.htmlBuild = buildRecipePaths:path(destFolderShellPath, 'html')
	self.dviBuild = buildRecipePaths:path(destFolderShellPath, 'dvi')
	self.docBuild = buildRecipePaths:path(destFolderShellPath, 'doc')
	self.psBuild = buildRecipePaths:path(destFolderShellPath, 'ps')

	self.binCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'bin')
	self.sbinCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'sbin')
	self.libexecCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'libexec')
	self.etcCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'etc')
	self.comCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'com')
	self.varCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'var')
	self.libCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'lib')
	self.includeCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'include')
	self.oldincludeCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'oldinclude')
	self.shareCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'share')
	self.dataCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'data')
	self.infoCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'info')
	self.localeCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'locale')
	self.manCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'man')
	self.docCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'doc')
	self.htmlCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'html')
	self.dviCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'dvi')
	self.docCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'doc')
	self.psCrossDestination = crossRecipePaths:destinationPath(destFolderShellPath, 'ps')
end

function module:__call(...)
	return self.actions(...)
end
