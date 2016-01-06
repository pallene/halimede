--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local type = halimede.type
local newline = halimede.packageConfiguration.newline


local environmentVariable = 'HALIMEDE_TRACE'
if type.hasPackageChildFieldOfTypeFunctionOrCall('debug', 'sethook', 'getinfo') and type.hasPackageChildFieldOfTypeFunctionOrCall('string', 'format') and type.hasPackageChildFieldOfTypeTableOrUserdata('io', 'stderr') and type.hasGlobalOfTypeFunctionOrCall('pcall') then
	local enableTracing = halimede.getenv(environmentVariable)
	if enableTracing ~= nil and enableTracing == 'true' then

		local function functionKeyword(language, nameWhat)
			local functionKeyword
			if language == 'Lua' then
				if nameWhat == 'upvalue' then
					return ''
				else
					return ' function'
				end
			else
				return ''
			end
		end

		local function sourceText(language, info)
			if language == 'C' then
				return ''
			else
				local source = info.source
				local currentLineNumber = info.currentline
				local currentLine = (currentLineNumber == -1) and '' or (' in %s%s'):format(source, currentLine)
				return (' in %s%s'):format(source, currentLine)
			end
		end

		local getinfo = debug.getinfo
		local stderr = io.stderr
		debug.sethook(function(event)
			local info = getinfo(2, 'nSl')

			local nameWhat = info.namewhat
			if nameWhat == '' then
				nameWhat = 'unknown'
			end

			local language = info.what
			local functionKeyword = functionKeyword(language, nameWhat)
			local sourceText = sourceText(language, info)

			local functionName = info.name or '?'

			local function write()
				stderr:write(("%s %s %s%s '%s'%s" .. newline):format(event, language, nameWhat, functionKeyword, functionName, sourceText))
			end
			local _, _ = pcall(write)
		end, 'cr')
	end
end
