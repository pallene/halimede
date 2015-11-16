--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local AbstractPath = moduleclass('AbstractPath')

local class = require('halimede.middleclass')
local Object = class.Object
local tabelize = require('halimede.table.tabelize').tabelize
local halimede = require('halimede')
local assert = halimede.assert
local syscall = require('syscall')
local exception = require('halimede.exception')

local AbsolutePath = requireSibling('AbsolutePath')
local RelativePath = requireSibling('RelativePath')


AbstractPath.static.fail = function(syscallName, path, becauseOfReason)
	exception.throwWithLevelIncrement(2, "Could not %s path '%s' because %s", syscallName, path, becauseOfReason)
end

-- Does not work for Windows paths such as C:FILE.TXT, \path\with\leading\separator (which is relative), and the use of '/' as an alternative folder separator (not valid for UNC paths)
-- Or for /current/drive/file.txt (ie relative to the current disk)
-- Probably doesn't work for OpenVMS...
assert.globalTableHasChieldFieldOfTypeFunction('string', 'len', 'sub')
AbstractPath.static.parse = function(folderSeparator, stringPath)
	assert.parameterTypeIsString(stringPath)
	if stringPath:len() == 0 then
		exception.throw('Parameter stringPath can not be empty')
	end
	
	if folderSeparator == '/' then
		if stringPath:sub(1, 1) == pathSeparator then
			return AbsolutePath:new(folderSeparator, stringPath:split(folderSeparator))
		else
			return RelativePath:new(folderSeparator, stringPath:split(folderSeparator))
		end
	end
	
	
	
	
	TODO: Plus also remove dependency on global folder separaotr
	TODO: Consider having Windows, Posix, Other path classes as folderSeparator not enough if ever need to support OpenVMS or Risc OS?
	
	
	
	xxxxxx
	
	-- Windows UNC
	if stringPath:sub(1, 2) == '\\\\' then
		-- Lots of yucky combinations, see https://en.wikipedia.org/wiki/Path_%28computing%29, we just extract * from \\*\
		
	-- Windows Drive Letter (Might be either C:file.txt or C:\file.txt)	
	elseif stringPath:sub(2, 1) == ':' then
		
	else
		return 
	end
end

assert.globalTypeIsFunction('ipairs')
function AbstractPath:initialize(folderSeparator, isRelative, initialPathPrefix, ...)
	assert.parameterTypeIsBoolean(isRelative)
	assert.parameterTypeIsString(initialPathPrefix)
	
	local folders = tabelize({...})
	for index, folder in ipairs(folders) do
		assert.parameterTypeIsString(folder)
		
		if folder:match('\0') ~= nil then
			exception.throw("Folder name at index '%s' contains ASCII NUL", index)
		end
		if folder:match(folderSeparator) ~= nil then
			exception.throw("Folder name at index '%s' contains folder separator '%s'", index, folderSeparator)
		end
	end
	
	self.folderSeparator = folderSeparator
	self.isRelative = isRelative
	self.initialPathPrefix = initialPathPrefix
	self.isAbsolute = not isRelative
	self.folders = folders
	self.path = initialPathPrefix .. folders:concat(folderSeparator)
end

function AbsolutePath:__tostring()
	return self.class.name .. '(' .. self.path .. ')'
end

function AbstractPath:__eq(right)
	if right == nil then
		return false
	end
	if not Object.isInstanceOf(value, self.class) then
		return false
	end
	return self.path == right.path
end

assert.globalTypeIsFunction('ipairs', 'unpack')
function AbsolutePath:_appendSubFolders(childFoldersTable)
	
	local folders = tabelize(shallowCopy(self.folders))
	for _, childFolder in ipairs(childFoldersTable) do
		folders:insert(childFolder)
	end
	
	return self:_construct(unpack(folders))
end

function AbstractPath:appendSubFolders(...)
	return self:_appendSubFolders(tabelize({...}))
end

function AbstractPath:appendRelativePathOf(relativePath)
	assert.parameterTypeIsInstanceOf(relativePath, RelativePath)
	if relativePath.folderSeparator ~= self.folderSeparator then
		exception.throw("relativePath '%s' has an incompatible folderSeparator '%s' (should be '%s')", relativePath.path, relativePath.folderSeparator, self.folderSeparator)
	end
	
	return self:_appendSubFolders(relativePath.folders)
end

-- returns a table containing fields: dev, ino, typename (st_mode), nlink, uid, gid, rdev, access, modification, change, size, blocks, blksize, islnk, isreg, ischr, isfifo, rdev.major, rdev.minor, rdev.device
function AbstractPath:stat()
	
	local path = self.path
	
	local ok, errorCode = syscall.stat(path)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('stat', path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/stat.html
	if errorCode.ACCES then
		failure('search permission is denied on a component of the path prefix')
	elseif errorCode.IO then
		failure('an error occurred while reading from the file system')
	elseif errorCode.LOOP then
		failure('too many symbolic links were encountered in resolving path')
	elseif errorCode.NAMETOOLONG then
		failure('the length of the path argument exceeds {PATH_MAX} or a pathname component is longer than {NAME_MAX}')
	elseif errorCode.NOENT then
		failure('a component of path does not name an existing file or path is an empty string')
	elseif errorCode.NOTDIR then
		failure('a component of the path prefix is not a directory')
	elseif errorCode.OVERFLOW then
		failure('the file size in bytes or the number of blocks allocated to the file or the file serial number cannot be represented correctly in the structure pointed to by buf')
	else
		failure(tostring(errorCode))
	end
end

function AbstractPath:lstat()
	
	local path = self.path
	
	local ok, errorCode = syscall.lstat(path)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('lstat', path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/lstat.html
	if errorCode.ACCES then
		failure('search permission is denied on a component of the path prefix')
	elseif errorCode.IO then
		failure('an error occurred while reading from the file system')
	elseif errorCode.LOOP then
		failure('too many symbolic links were encountered in resolving path')
	elseif errorCode.NAMETOOLONG then
		failure('the length of the path argument exceeds {PATH_MAX} or a pathname component is longer than {NAME_MAX}')
	elseif errorCode.NOTDIR then
		failure('a component of the path prefix is not a directory')
	elseif errorCode.NOENT then
		failure('a component of path does not name an existing file or path is an empty string')
	elseif errorCode.OVERFLOW then
		failure('the file size in bytes or the number of blocks allocated to the file or the file serial number cannot be represented correctly in the structure pointed to by buf')
	else
		failure(tostring(errorCode))
	end
end

function AbstractPath:makeCharacterDevice(mode, major, minor)
	assert.parameterTypeIsString(mode)
	assert.parameterTypeIsNumber(major)
	assert.parameterTypeIsNumber(minor)
	
	local path = self.path
	-- Seems there's a device() method, too
	local device = {major, minor}
	
	local ok, errorCode = syscall.mknod(path, 'fchr,' .. mode, device)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('mknod', path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/mknod.html
	if errorCode.PERM then
		failure('the invoking process does not have appropriate privileges and the file type is not FIFO-special')
	elseif errorCode.NOTDIR then
		failure('a component of the path prefix is not a directory')
	elseif errorCode.NOENT then
		failure('a component of the path prefix specified by path does not name an existing directory or path is an empty string')
	elseif errorCode.ACCES then
		failure('a component of the path prefix denies search permission, or write permission is denied on the parent directory')
	elseif errorCode.ROFS then
		failure('the directory in which the file is to be created is located on a read-only file system')
	elseif errorCode.EXIST then
		failure('the named file exists')
	elseif errorCode.IO then
		failure('an I/O error occurred while accessing the file system')
	elseif errorCode.INVAL then
		failure('an invalid argument exists')
	elseif errorCode.NOSPC then
		failure('the directory that would contain the new file cannot be extended or the file system is out of file allocation resources')
	elseif errorCode.LOOP then
		failure('too many symbolic links were encountered in resolving path')
	elseif errorCode.NAMETOOLONG then
		failure('the length of a pathname exceeds {PATH_MAX}, or pathname component is longer than {NAME_MAX}')
	else
		failure(tostring(errorCode))
	end
	
end

function AbstractPath:mkfifo(mode)
	assert.parameterTypeIsString(mode)
	
	local path = self.path
	local ok, errorCode = syscall.mkfifo(path, mode)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('mkfifo', path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/mkfifo.html
	if errorCode.ACCES then
		failure('a component of the path prefix denies search permission, or write permission is denied on the parent directory of the FIFO to be created')
	elseif errorCode.EXIST then
		self.chmod(mode)
		return
	elseif errorCode.LOOP then
		failure('too many symbolic links were encountered in resolving path')
	elseif errorCode.NAMETOOLONG then
		failure('the length of the path argument exceeds {PATH_MAX} or a pathname component is longer than {NAME_MAX}')
	elseif errorCode.NOENT then
		failure('a component of the path prefix specified by path does not name an existing directory or path is an empty string')
	elseif errorCode.NOTDIR then
		failure('a component of the path prefix is not a directory')
	elseif errorCode.ROFS then
		failure('the named file resides on a read-only file system')
	else
		failure(tostring(errorCode))
	end
end

function AbstractPath:chmod(mode)
	assert.parameterTypeIsString(mode)
	
	local path = self.path
		
	local function failure(becauseOfReason)
		AbstractPath.fail('chmod', path, becauseOfReason)
	end
	
	local ok = false
	local errorCode
	-- Can be interrupted
	repeat
		
		ok, errorCode = syscall.chmod(path, mode)
		if ok then
			return
		end
		
		-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/chmod.html
		if errorCode.ACCES then
			failure('search permission is denied on a component of the path prefix')
		elseif errorCode.LOOP then
			failure('too many symbolic links were encountered in resolving path')
		elseif errorCode.NAMETOOLONG then
			failure('the length of the path argument exceeds {PATH_MAX} or a pathname component is longer than {NAME_MAX}')
		elseif errorCode.NOTDIR then
			failure('a component of the path prefix is not a directory')
		elseif errorCode.NOENT then
			failure('a component of path does not name an existing file or path is an empty string')
		elseif errorCode.PERM then
			failure('the effective user ID does not match the owner of the file and the process does not have appropriate privileges')
		elseif errorCode.ROFS then
			failure('the parent directory resides on a read-only file system')
		elseif errorCode.INTR then
			-- Interrupted; retry
		elseif errorCode.INVAL then
			failure('the value of the mode argument is invalid')
		else
			failure(tostring(errorCode))
		end
		
	until ok
end

-- Can not create '/' or C:\
function AbstractPath:mkdirParents(mode, initialPathPrefix)
	assert.parameterTypeIsString(mode)
	
	local path
	
	local function failure(becauseOfReason)
		AbstractPath.fail('mkdir', path, becauseOfReason)
	end
	
	local folderSeparator = self.folderSeparator
	
	local length = #self.folders
	for index, folder in ipairs(self.folders) do
		if index == 1 then
			path = self.initialPathPrefix .. folder
		else
			path = path .. folderSeparator .. folder
		end
	
		local isLastFolder = index == length
	
		local mode_t
		if isLastFolder then
			mode_t = helpers.modeflags(mode)
		else
			mode_t = '0700'
		end
	
		local ok, errorCode = syscall.mkdir(concatenatedPath, mode_t)
	
		if ok then
			if isLastFolder then
				self:chmod(mode)
			end
		else
			-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/mkdir.html
			if errorCode.ACCES then
				if isLastFolder then
					failure('search permission is denied on a component of the path prefix, or write permission is denied on the parent directory of the directory to be created')
				else
					-- Do nothing
				end
			elseif errorCode.EXIST then
				if isLastFolder then
					self:chmod(mode)
				else
					-- Do nothing
				end
			elseif errorCode.LOOP then
				failure('too many symbolic links were encountered in resolving path')
			elseif errorCode.MLINK then
				failure('the link count of the parent directory would exceed {LINK_MAX}')
			elseif errorCode.NAMETOOLONG then
				failure('a component of the path prefix specified by path does not name an existing directory or path is an empty string')
			elseif errorCode.NOENT then
				failure('the length of the path argument exceeds {PATH_MAX} or a pathname component is longer than {NAME_MAX}')
			elseif errorCode.NOSPC then
				failure('the file system does not contain enough space to hold the contents of the new directory or to extend the parent directory of the new directory')
			elseif errorCode.NOTDIR then
				failure('a component of the path prefix is not a directory')
			elseif errorCode.ROFS then
				failure('the parent directory resides on a read-only file system')
			else
				failure(tostring(errorCode))
			end
		end
	end
end
