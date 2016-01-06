--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local ShellScript = halimede.io.shellScript.ShellScript
local ShellPath = halimede.io.shellScript.ShellPath
local Actions = halimede.build.toolchain.Actions
local Platform = haimede.build.toolchain.Platform
local RecipePaths = haimede.build.toolchain.RecipePaths
local AbstractStrip = haimede.build.shellScriptActions.strip.AbstractStrip
local ConfigHDefines = haimede.build.defines.ConfigHDefines


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

	self.binBuild = crossRecipePaths:path('bin')
	self.sbinBuild = crossRecipePaths:path('sbin')
	self.libexecBuild = crossRecipePaths:path('libexec')
	self.etcBuild = crossRecipePaths:path('etc')
	self.comBuild = crossRecipePaths:path('com')
	self.varBuild = crossRecipePaths:path('var')
	self.libBuild = crossRecipePaths:path('lib')
	self.includeBuild = crossRecipePaths:path('include')
	self.oldincludeBuild = crossRecipePaths:path('oldinclude')
	self.shareBuild = crossRecipePaths:path('share')
	self.dataBuild = crossRecipePaths:path('data')
	self.infoBuild = crossRecipePaths:path('info')
	self.localeBuild = crossRecipePaths:path('locale')
	self.manBuild = crossRecipePaths:path('man')
	self.docBuild = crossRecipePaths:path('doc')
	self.htmlBuild = crossRecipePaths:path('html')
	self.dviBuild = crossRecipePaths:path('dvi')
	self.docBuild = crossRecipePaths:path('doc')
	self.psBuild = crossRecipePaths:path('ps')

	self.binCross = buildRecipePaths:path('bin')
	self.sbinCross = buildRecipePaths:path('sbin')
	self.libexecCross = buildRecipePaths:path('libexec')
	self.etcCross = buildRecipePaths:path('etc')
	self.comCross = buildRecipePaths:path('com')
	self.varCross = buildRecipePaths:path('var')
	self.libCross = buildRecipePaths:path('lib')
	self.includeCross = buildRecipePaths:path('include')
	self.oldincludeCross = buildRecipePaths:path('oldinclude')
	self.shareCross = buildRecipePaths:path('share')
	self.dataCross = buildRecipePaths:path('data')
	self.infoCross = buildRecipePaths:path('info')
	self.localeCross = buildRecipePaths:path('locale')
	self.manCross = buildRecipePaths:path('man')
	self.docCross = buildRecipePaths:path('doc')
	self.htmlCross = buildRecipePaths:path('html')
	self.dviCross = buildRecipePaths:path('dvi')
	self.docCross = buildRecipePaths:path('doc')
	self.psCross = buildRecipePaths:path('ps')

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
