--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('halimede.middleclass')
local Object = class.Object
local CompileUnitActions = requireSibling('CompileUnitActions')
local AbstractPath = require('halimede.io.paths.AbstractPath')
local AbsolutePath = require('halimede.io.paths.AbsolutePath')
local RelativePath = require('halimede.io.paths.RelativePath')
local ShellLanguage = require('halimede.io.ShellLanguage')


local WindowsCompileUnitActions = class('WindowsCompileUnitActions', CompileUnitActions)

function WindowsCompileUnitActions:initialize(sourcePath, sysrootPath, toolchain)
	AbstractCompileUnitActions.initialise(self, ShellLanguage.Windows, sourcePath, sysrootPath, toolchain)
end

function WindowsCompileUnitActions:_initialBuildScript()
	
	-- Can't use a multiline string because the new line terminator is then wrong
	self:appendLinesToBuildScript(
		'@ECHO OFF',
		'SETLOCAL EnableExtensions'
	)
end

assert.globalTypeIsFunction('unpack')
function WindowsCompileUnitActions:_finalBuildScript()
	self:appendLinesToBuildScript('ENDLOCAL')
end

function WindowsCompileUnitActions:actionUnsetEnvironmentVariable(variableName)
	assert.parameterTypeIsString(variableName)
	
	self:appendCommandLineToBuildScript('UNSET', '/Q', variableName)
end

function PosixCompileUnitActions:actionExportEnvironmentVariable(variableName, variableValue)
	assert.parameterTypeIsString(variableName)
	assert.parameterTypeIsString(variableValue)
	
	self:appendCommandLineToBuildScript('SET', variableName .. '=' .. variableValue)
end

-- http://ss64.com/nt/path.html
function WindowsCompileUnitActions:actionSetPath(paths)
	assert.parameterTypeIsInstanceOf(paths, Paths)
	
	self:appendCommandLineToBuildScript('PATH', ';')
	self:appendCommandLineToBuildScript('PATH', paths.paths)
end

function WindowsCompileUnitActions:actionChangeDirectory(abstractPath)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)

	if Object.isInstanceOf(abstractPath, AbsolutePath) then
		self:appendCommandLineToBuildScript('CD', '/D', abstractPath.path)
	else
		self:appendCommandLineToBuildScript('CD', abstractPath.path)
	end
end

-- Problems with Windows mkdir if command extensions are not enabled: https://stackoverflow.com/questions/905226/mkdir-p-linux-windows#905239 (we do this in _initialBuildScript)
function WindowsCompileUnitActions:actionMakeDirectoryParent(abstractPath, mode)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)
	assert.parameterTypeIsString(mode)
	
	-- We use MD to differentiate from mkdir, which can be present if GNU Utils for Windows are installed
	self:appendCommandLineToBuildScript('MD', abstractPath.path)
end

-- Lua has os.remove(), which is semantically the same as rmdir, but since we can't iterate the directory contents, how can we delete?
-- Not really equivalent to rm -rf; doesn't delete files. See https://stackoverflow.com/questions/97875/rm-rf-equivalent-for-windows
function WindowsCompileUnitActions:actionRemoveRecursivelyWithForce(abstractPath)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)
	
	self:appendCommandLineToBuildScript('RD', '/S', '/Q', abstractPath.path)
end

return WindowsCompileUnitActions
