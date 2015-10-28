--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = require('halimede.assert')
local syscall = require('syscall')
local exception = require('halimede.exception')
local tabelize = require('halimede.tabelize')
local helpers = require('syscall.helpers')

-- syscall.umask('0000')

local class = require('middleclass')


local AbstractPath = class('AbstractPath')

local folderSeparator = halimede.packageConfiguration.folderSeparator
function AbstractPath:initialize(isRelative, ...)
	self.folders = tabelize({...})
	
	for index, folder in ipairs(self.folders) do
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
	self.isAbsolute = not isRelative
	self.path = self.concatenate()
end

AbstractPath.static.fail = function(syscallName, path, becauseOfReason)
	exception.throwWithLevelIncrement(1, "Could not %s path '%s' because %s", syscallName, path, becauseOfReason)
end

function AbstractPath:makeCharacterDevice(mode, major, minor)
	assert.parameterTypeIsString(mode)
	assert.parameterTypeIsNumber(major)
	assert.parameterTypeIsNumber(minor)
	
	-- Seems there's a device() method, too
	local device = {major, minor}
	
	local ok, errorCode = syscall.mknod(self.path, 'fchr,' .. mode, device)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('mknod', self.path, becauseOfReason)
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
	
	local ok, errorCode = syscall.mkfifo(self.path, mode)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('mkfifo', self.path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/mkfifo.html
	if errorCode.ACCES then
		failure('a component of the path prefix denies search permission, or write permission is denied on the parent directory of the FIFO to be created')
	if errorCode.EXIST then
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

-- returns a table containing fields: dev, ino, typename (st_mode), nlink, uid, gid, rdev, access, modification, change, size, blocks, blksize, islnk, isreg, ischr, isfifo, rdev.major, rdev.minor, rdev.device
function AbstractPath:stat()
	
	local ok, errorCode = syscall.stat(self.path)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('stat', self.path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/stat.html
	if errorCode.ACCES then
		failure('search permission is denied on a component of the path prefix')
	if errorCode.IO then
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
	
	local ok, errorCode = syscall.lstat(self.path)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		AbstractPath.fail('lstat', self.path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/stat.html
	if errorCode.ACCES then
		failure('search permission is denied on a component of the path prefix')
	if errorCode.IO then
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

function AbstractPath:chmod(mode)
	assert.parameterTypeIsString(mode)
	
	local ok = false
	local errorCode
	
	-- Can be interrupted
	repeat
		
		ok, errorCode = syscall.chmod(self.path, mode)
		if ok then
			break
		end
		
		local function failure(becauseOfReason)
			AbstractPath.fail('chmod', self.path, becauseOfReason)
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
			-- Retry
		elseif errorCode.INVAL then
			failure('the value of the mode argument is invalid')
		else
			failure(tostring(errorCode))
		end
		
	until ok
end

function AbstractPath:mkdirParents(mode, initialPathPrefix)
	assert.parameterTypeIsString(mode)
	
	local path
	
	local function failure(becauseOfReason)
		AbstractPath.fail('mkdir', path, becauseOfReason)
	end

	local length = #self.folders
	for index, folder in ipairs(self.folders) do
		if index == 1 then
			path = initialPathPrefix .. folder
		else
			path = path .. self.folderSeparator .. folder
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
				path:chmod(mode)
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
					path:chmod(mode)
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

local RelativePath = class('RelativePath', AbstractPath)

function RelativePath:initialize(...)
	AbstractPath.initialize(self, true, ...)
end

function RelativePath:concatenate()
	return self.folders:concat(self.folderSeparator)
end

function RelativePath:mkdirParents(mode)
	assert.parameterTypeIsString(mode)
	
	return AbstractPath.mkdirParents(self, mode, '')
end


local AbsolutePath = class('AbsolutePath', AbstractPath)

-- eg C:\temp => absolutePath('C:', 'temp')
-- eg \\server\admin$\system32 => absolutePath('\\server\admin$', 'system32') [admin$ is usually C:\WINDOWS or C:\WINNT]
-- eg \\server\temp (C:\temp, probably) => absolutePath('\\server', 'temp')
-- eg /usr/bin => absolutePath('', 'usr', 'bin')
function AbsolutePath:initialize(driveOrUncPrefixIfWindows, ...)
	assert.parameterTypeIsString(driveOrUncPrefixIfWindows)
	
	AbstractPath.initialize(self, false, ...)

	if self.folderSeparator == '\\' then
		self.driveOrUncPrefixIfWindows = driveOrUncPrefixIfWindows
	else
		self.driveOrUncPrefixIfWindows = ''
	end
end

function AbsolutePath:concatenate()
	return self.driveOrUncPrefixIfWindows .. self.folderSeparator .. self.folders:concat(self.folderSeparator)
end

-- Can not create '/' or C:\
function AbsolutePath:mkdirParents(mode)
	assert.parameterTypeIsString(mode)
	
	return AbstractPath.mkdirParents(self, mode, self.driveOrUncPrefixIfWindows .. self.folderSeparator)
end
