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

	self.binCross = crossRecipePaths:path('bin')
	self.sbinCross = crossRecipePaths:path('sbin')
	self.libexecCross = crossRecipePaths:path('libexec')
	self.etcCross = crossRecipePaths:path('etc')
	self.comCross = crossRecipePaths:path('com')
	self.varCross = crossRecipePaths:path('var')
	self.libCross = crossRecipePaths:path('lib')
	self.includeCross = crossRecipePaths:path('include')
	self.oldincludeCross = crossRecipePaths:path('oldinclude')
	self.shareCross = crossRecipePaths:path('share')
	self.dataCross = crossRecipePaths:path('data')
	self.infoCross = crossRecipePaths:path('info')
	self.localeCross = crossRecipePaths:path('locale')
	self.manCross = crossRecipePaths:path('man')
	self.docCross = crossRecipePaths:path('doc')
	self.htmlCross = crossRecipePaths:path('html')
	self.dviCross = crossRecipePaths:path('dvi')
	self.docCross = crossRecipePaths:path('doc')
	self.psCross = crossRecipePaths:path('ps')

	self.binBuild = buildRecipePaths:path('bin')
	self.sbinBuild = buildRecipePaths:path('sbin')
	self.libexecBuild = buildRecipePaths:path('libexec')
	self.etcBuild = buildRecipePaths:path('etc')
	self.comBuild = buildRecipePaths:path('com')
	self.varBuild = buildRecipePaths:path('var')
	self.libBuild = buildRecipePaths:path('lib')
	self.includeBuild = buildRecipePaths:path('include')
	self.oldincludeBuild = buildRecipePaths:path('oldinclude')
	self.shareBuild = buildRecipePaths:path('share')
	self.dataBuild = buildRecipePaths:path('data')
	self.infoBuild = buildRecipePaths:path('info')
	self.localeBuild = buildRecipePaths:path('locale')
	self.manBuild = buildRecipePaths:path('man')
	self.docBuild = buildRecipePaths:path('doc')
	self.htmlBuild = buildRecipePaths:path('html')
	self.dviBuild = buildRecipePaths:path('dvi')
	self.docBuild = buildRecipePaths:path('doc')
	self.psBuild = buildRecipePaths:path('ps')

	local function destinationPath(path)
		return self.destFolderShellPath:appendAbsolutePathAsRelativePath(path)
	end

	self.binCrossDestination = destinationPath(self.binCross)
	self.sbinCrossDestination = destinationPath(self.sbinCross)
	self.libexecCrossDestination = destinationPath(self.libexecCross)
	self.etcCrossDestination = destinationPath(self.etcCross)
	self.comCrossDestination = destinationPath(self.comCross)
	self.varCrossDestination = destinationPath(self.varCross)
	self.libCrossDestination = destinationPath(self.libCross)
	self.includeCrossDestination = destinationPath(self.includeCross)
	self.oldincludeCrossDestination = destinationPath(self.oldincludeCross)
	self.shareCrossDestination = destinationPath(self.shareCross)
	self.dataCrossDestination = destinationPath(self.dataCross)
	self.infoCrossDestination = destinationPath(self.infoCross)
	self.localeCrossDestination = destinationPath(self.localeCross)
	self.manCrossDestination = destinationPath(self.manCross)
	self.docCrossDestination = destinationPath(self.docCross)
	self.htmlCrossDestination = destinationPath(self.htmlCross)
	self.dviCrossDestination = destinationPath(self.dviCross)
	self.docCrossDestination = destinationPath(self.docCross)
	self.psCrossDestination = destinationPath(self.psCross)
end

function module:__call(...)
	return self.actions(...)
end
