--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local shellLanguage = require('halimede.io.SearchLanguage').Default
local openTextModeForReading = require('halimede.io.read').openTextModeForReading


local function shellIsAvailable()
	if not type.hasPackageChildFieldOfTypeFunctionOrCall('os', 'execute') then
		return false
	end
	return os.execute()
end
module.shellIsAvailable = shellIsAvailable()
local shellIsAvailable = module.shellIsAvailable
local noShellIsAvailable = not shellIsAvailable

-- NOTE: This approach is slow, as it opens the executable for reading
-- NOTE: This approach can not determine if a binary is +x (executable) or not
assert.globalTypeIsFunction('pcall')
function module.commandIsOnPath(command)
	assert.parameterTypeIsString('command', command)
	
	for path in shellLanguage:binarySearchPath():iterate() do
		local pathToBinary = path:appendFile(command)
		
		local ok, fileHandleOrError = pcall(openTextModeForReading, pathToBinary, command)
		if ok then
			local fileHandle = fileHandleOrError
			fileHandle:close()
			return true, pathToBinary
		end
	end
	
	return false, nil
end
local commandIsOnPath = module.commandIsOnPath

function module.commandIsOnPathAndShellIsAvaiableToUseIt(command)
	assert.parameterTypeIsString('command', command)
	
	if noShellIsAvailable then
		return false
	end
	
	return commandIsOnPath(command)
end
