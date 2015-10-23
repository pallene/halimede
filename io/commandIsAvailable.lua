--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local shellLanguage = require('halimede.io.SearchLanguage').Default
local concatenateToPath = halimede.concatenateToPath
local openTextModeForReading = require('halimede.io.read').openTextModeForReading


-- NOTE: This approach is slow, as it opens the executable for reading
-- NOTE: This approach can not determine if a binary is +x (executable) or not
assert.globalTableHasChieldFieldOfTypeFunction('os', 'getenv', 'execute')
function module.commandIsOnPath(command)
	assert.parameterTypeIsString(command)
	
	for path in shellLanguage.iteratePath(shellLanguage.binarySearchPath) do
		local pathToBinary = concatenateToPath(path, command)
		
		local ok, fileHandleOrError = pcall(openTextModeForReading, absolutePath, command)
		if ok then
			local fileHandle = fileHandleOrError
			fileHandle:close()
			return true, pathToBinary
		end
	end
	
	return false, nil
end
