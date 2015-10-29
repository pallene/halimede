--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('middleclass')
local CompileUnitActions = requireSibling('CompileUnitActions')
local AbstractPath = require('halimede.io.paths.AbstractPath')
local ShellLanguage = require('halimede.io.ShellLanguage')


local PosixCompileUnitActions = class('PosixCompileUnitActions', CompileUnitActions)

function PosixCompileUnitActions:initialize(sourcePath, sysrootPath, compilerDriver)
	AbstractCompileUnitActions.initialise(self, ShellLanguage.POSIX, sourcePath, sysrootPath, compilerDriver)
end

function PosixCompileUnitActions:_initialBuildScript()
	-- Can't use a multiline string because the new line terminator is wrong if this file is edited by some Windows programs
	return
		'#!/usr/bin/env sh',
		'set -e',
		'set -u',
		'set -f'
end

function PosixCompileUnitActions:_finalBuildScript()
	return
end

function PosixCompileUnitActions:actionChangeDirectory(abstractPath)
	assert.parameterTypeIsInstanceOf(sourcePath, AbstractPath)
	
	self:appendCommandLineToBuildScript('cd', abstractPath.path)
end

function PosixCompileUnitActions:actionMakeDirectoryParent(abstractPath, mode)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)
	assert.parameterTypeIsString(mode)

	assert.parameterTypeIsString(mode)
	
	self:appendCommandLineToBuildScript('mkdir', '-m', mode, '-p', abstractPath, mode.path)
end

function PosixCompileUnitActions:actionRemoveRecursivelyWithForce(abstractPath)
	assert.parameterTypeIsInstanceOf(abstractPath, AbstractPath)
	
	self:appendCommandLineToBuildScript('rm', '-rf', abstractPath.path)
end
