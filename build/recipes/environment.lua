--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


--[[
Actions in scope:-
	writeConfigH
	compilerDriverPreprocessAndCompile
	compilerDriverLinkExecutable

	Perhaps these should simply be functions that return a command line?
]]--

folderSeparator = '/'
pathSeparator = ':'
newLine = '\n'
objectExtension = '.o'
executableExtension = ''  -- Might be .exe on Windows

staticLibraryPrefix = 'lib'
staticLibraryExtension = '.a'
dynamicLibraryPrefix = 'lib'
dynamicLibraryExtension = '.so' -- might be .dylib on Mac OS X but might not be if using Lua

sysrootPath = '/opt'
destinationPath = '/opt/package/version'  -- Where version is, say, 2.0.4-lua-5.2 and package is luarocks


function quotedStringDefine(value)
	return '"' .. value .. '"'
end

function concatenateToPath(...)
	return table.concat({...}, folderSeparator)
end

function concatenateToPaths(...)
	return table.concat({...}, pathSeparator)
end

function addFileExtensionToFileNames(extensionWithLeadingPeriod, ...)
	local asTable
	if select('#', ...) == 1 then
		if type(...) == 'table' then
			asTable = select(1, ...)
		else
			asTable = {...}
		end
	else
		asTable = {...}
	end
	
	local result = {}
	for _, basefilename in ipairs(asTable) do
		table.insert(result, basefilename .. extensionWithLeadingPeriod)
	end
	return result
end

function toCFiles(...)
	return addFileExtensionToFileNames('.c', ...)
end

function toObjects(...)
	return addFileExtensionToFileNames(objectExtension, ...)
end
