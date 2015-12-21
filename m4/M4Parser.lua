--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Path = halimede.io.paths.Path
local openBinaryFileForReading = halimede.io.FileHandleStream.openBinaryFileForReading
local tabelize = halimede.table.tabelize


moduleclass('M4Parser')

function module:initialize(m4FilePath)
	assert.parameterTypeIsInstanceOf('m4FilePath', m4FilePath, Path)
	
	m4FilePath:assertIsFilePath('m4FilePath')
	
	self.fileHandleStreamToReadFrom = openBinaryFileForReading(m4FilePath, 'M4 file')
	self.output = tabelize()
	
	self.commenting
	self.wording
	self.quoting
	
	self.
end

function module:_readByte()
	return self.fileHandleStreamToReadFrom:readByte()
end

function module:_writeByte(byte)
	self.output:insert(byte)
end

function module:_writeBytes(bytes)
	self.output:insert(bytes)
end

function module:_finished()
	print(self.output:concat())
end

function module:_readLoop(byteUserFunction, bytesFinishedFunction)
	local prefix = ''
	local state = {}
	local byte = self:_readByte()
	while byte ~= false do
		
		prefix = prefix .. byte
		prefix, state = byteUserFunction(self, prefix, state)
				
		byte = self:_readByte()
	end
	bytesFinishedFunction(self, prefix, state)
end


local function readTokensByteUser(self, prefix, state)
	
	-- Comments, Macros, Quoted Strings
	
	
	
	
	
	
	
	
	
	if self.commenting:prefixMatchesBeginComment(prefix) then
		self:readComment(prefix)
		return '', {}
	-- ie matches a valid macro pattern AND is an extant macro possibility
	elseif self.wording:prefixMatchesBeginWord(prefix) then
		self:readWord(prefix)
		return '', {}
	elseif self.quoting:prefixMatchesBeginQuote(prefix) then
		self:readQuote(prefix)
		return '', {}
	else
		self:writeBytes(prefix)
		return prefix, state
	end
end

local function readTokensBytesFinished(self, state)
	self:_finished()
end

function module:readTokens()
	self:_readLoop(readTokensByteUser, readTokensBytesFinished)
end



local function readComment(self, state, byte)
end

function module:readComment(prefix)
	self:_writeBytes(prefix)
	self:_readLoop(readTokensByteUser, doNothingBytesFinished)
end

--[[
	threading can be posix, solaris, pth or windows (pth and solaris really aren't needed)
	./configure --disable-rpath --enable-threads=posix --without-libsigsegv-prefix --without-libpth-prefix --with-included-regex --with-syscmd-shell=/bin/sh

	Also supports --with-dmalloc (for debug builds)

]]--