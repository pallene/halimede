--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local FileHandleStream = halimede.io.FileHandleStream
local format = halimede.string.format
local exception = halimede.exception


halimede.moduleclass('Messages')

--  --quiet, --silent or -Q
-- warnings usually go to stderr
-- traces usually go to stderr
function module:initialize(lineDelimiter, isQuiet, warningFileHandleStream, debugFileHandleStream, standardErrorFileHandleStream)
	assert.parameterTypeIsString('lineDelimiter', lineDelimiter)
	assert.parameterTypeIsBoolean('isQuiet', isQuiet)
	assert.parameterTypeIsInstanceOf('warningFileHandleStream', warningFileHandleStream, FileHandleStream)
	assert.parameterTypeIsInstanceOf('debugFileHandleStream', debugFileHandleStream, FileHandleStream)
	assert.parameterTypeIsInstanceOf('standardErrorFileHandleStream', standardErrorFileHandleStream, FileHandleStream)

	self.lineDelimiter = lineDelimiter
	self.isQuiet = isQuiet
	self.shouldWrite = not isQuiet
	self.warningFileHandleStream = warningFileHandleStream
	self.debugFileHandleStream = debugFileHandleStream
	self.standardErrorFileHandleStream = standardErrorFileHandleStream


	self.currentFileName = 'stdin'
	self.currentLineNumber = 1


	self.isTracing = false
	self.traceMacroNames = {}
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:errorPrint(...)
	local arguments = {...}
	if #arguments == 0 then
		exception.throw("There should be at least one argument to the 'errprint' builtin")
	end

	for index, argument in ipairs(arguments) do
		if index > 1 then
			self.standardErrorFileHandleStream:writeIfOpen(' ')
		end
		self.standardErrorFileHandleStream:writeIfOpen(argument)
	end
end

function module:warning(template, ...)
	local message = format(template, ...)
	local line = format('m4:%s:%s: Warning: \n', self.currentFileName, self.currentLineNumber)
	if self.shouldWrite then
		self.warningFileHandleStream:writeIfOpen(line)
	end
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:traceOnAll(allCurrentlyDefinedMacros)
	self.isTracing = true
	for _, macroName in ipairs(allCurrentlyDefinedMacros) do
		self.onlyTraceMacroNames[macroName] = true
	end
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:traceOn(macroNames)
	self.isTracing = true
	for _, macroName in ipairs(macroNames) do
		self.traceMacroNames[macroName] = true
	end
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:traceOffAll(allCurrentlyDefinedMacros)
	self.isTracing = false
	for _, macroName in ipairs(allCurrentlyDefinedMacros) do
		self.traceMacroNames[macroName] = nil
	end
end

assert.globalTypeIsFunctionOrCall('ipairs')
function module:traceOff(macroNames)
	self.isTracing = false
	for _, macroName in ipairs(macroNames) do
		self.traceMacroNames[macroName] = nil
	end
end

function module:trace(macroName, expansionDepth, input, expansion)
	assert.parameterTypeIsString('macroName', macroName)
	assert.parameterTypeIsPositiveInteger('expansionDepth', expansionDepth)
	assert.parameterTypeIsString('input', input)
	assert.parameterTypeIsStringOrNil('expansion', expansion)

	if not self.isTracing then
		return
	end

	if self.traceMacroNames[macroName] == nil then
		return
	end

	-- nil is Void
	local formattedExpansion
	if expansion ~= nil then
		formattedExpansion = " -> `" .. expansion .. "'"
	else
		formattedExpansion = ''
	end

	local line = format("m4trace: -%s- %s%s", expansionDepth, input, formattedExpansion)
	self.debugFileHandleStream:writeIfOpen(line)
end
