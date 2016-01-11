--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local AbstractWriteConfigHShellScriptAction = halimede.build.shellScriptActions.AbstractWriteConfigHShellScriptAction
local CommentCmdShellScriptAction = halimede.build.shellScriptActions.CommentCmdShellScriptAction


halimede.moduleclass('WriteConfigHCmdShellScriptAction', AbstractWriteConfigHShellScriptAction)

-- https://stackoverflow.com/questions/7105433/windows-batch-echo-without-new-line
function module:initialize()
	AbstractWriteConfigHShellScriptAction.initialize(self, CommentCmdShellScriptAction, 'ECHO')
end
