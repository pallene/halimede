--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local Path = halimede.io.paths.Path
local openBinaryFileForReading = halimede.io.FileHandleStream.openBinaryFileForReading


-- builtin macros
moduleclass('Builtin')

function module:initialize(name, expansionText, symbolLookupMode)
end

--[[
Hashtable operations

enum symbol_lookup
{
  SYMBOL_LOOKUP,
  SYMBOL_INSERT,
  SYMBOL_DELETE,
  SYMBOL_PUSHDEF,
  SYMBOL_POPDEF
};
]]--
