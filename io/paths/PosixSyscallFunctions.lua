--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local exception = halimede.exception
local syscall = require('syscall')
local Path = requireSibling('Path')


local function fail = function(syscallName, path, becauseOfReason)
	exception.throwWithLevelIncrement(2, "Could not %s path '%s' because %s", syscallName, path, becauseOfReason)
end

-- returns a table containing fields: dev, ino, typename (st_mode), nlink, uid, gid, rdev, access, modification, change, size, blocks, blksize, islnk, isreg, ischr, isfifo, rdev.major, rdev.minor, rdev.device
assert.globalTypeIsFunction('tostring')
function module.stat(path)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	
	local ok, errorCode = syscall.stat(path:toString(false))
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		fail('stat', path, becauseOfReason)
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
local stat = module.stat

assert.globalTypeIsFunction('tostring')
function module.lstat(path)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	
	local ok, errorCode = syscall.lstat(path:toString(false))
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		fail('lstat', path, becauseOfReason)
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
local lstat = module.lstat

assert.globalTypeIsFunction('tostring')
function module.makeCharacterDevice(path, mode, major, minor)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	assert.parameterTypeIsString('mode', mode)
	assert.parameterTypeIsPositiveInteger('major', major)
	assert.parameterTypeIsPositiveInteger('minor', minor)
	
	-- Seems there's a device() method, too
	local device = {major, minor}
	
	local ok, errorCode = syscall.mknod(path:toString(false), 'fchr,' .. mode, device)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		fail('mknod', path, becauseOfReason)
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
local makeCharacterDevice = module.makeCharacterDevice

assert.globalTypeIsFunction('tostring')
function module.mkfifo(path, mode)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	assert.parameterTypeIsString('mode', mode)
	
	local ok, errorCode = syscall.mkfifo(path:toString(false), mode)
	if ok then
		return
	end
	
	local function failure(becauseOfReason)
		fail('mkfifo', path, becauseOfReason)
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/mkfifo.html
	if errorCode.ACCES then
		failure('a component of the path prefix denies search permission, or write permission is denied on the parent directory of the FIFO to be created')
	elseif errorCode.EXIST then
		chmod(path, mode)
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
local mkfifo = module.mkfifo

assert.globalTypeIsFunction('tostring')
function module.chmod(path, mode)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	assert.parameterTypeIsString('mode', mode)
		
	local function failure(becauseOfReason)
		fail('chmod', path, becauseOfReason)
	end
	
	local pathString = path:toString(false)
	local ok = false
	local errorCode
	-- Can be interrupted
	repeat
		
		ok, errorCode = syscall.chmod(pathString, mode)
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
local chmod = module.chmod

-- Can not make C:\ or / or C: or UNC-based paths
assert.globalTypeIsFunction('tostring')
function module.mkdir(path, mode, isLeaf)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	assert.parameterTypeIsString('mode', mode)
	assert.parameterTypeIsBooleanOrNil('isLeaf', isLeaf)
	
	path:assertIsFolderPath(path)
	
	if path.isDeviceOrRoot then
		return
	end
	
	local isLeafActual
	if isLeaf == nil then
		isLeafActual = true
	else
		isLeafActual = isLeaf
	end
	
	local function failure(becauseOfReason)
		fail('mkdir', path, becauseOfReason)
	end

	local mode_t = helpers.modeflags(mode)

	local ok, errorCode = syscall.mkdir(concatenatedPath, mode_t)
	if ok then
		if isLeaf then
			chmod(path, mode)
		end
		return true
	end
	
	-- Messages from http://pubs.opengroup.org/onlinepubs/7908799/xsh/mkdir.html
	if errorCode.ACCES then
		if isLeaf then
			failure('search permission is denied on a component of the path prefix, or write permission is denied on the parent directory of the directory to be created')
		else
			return false
		end
	elseif errorCode.EXIST then
		if isLeaf then
			chmod(path, mode)
		else
			-- Do nothing
		end
		return true
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
local mkdir = module.mkdir

function module.mkdirs(path, mode, isLeaf)
	assert.parameterTypeIsInstanceOf('path', path, Path)
	assert.parameterTypeIsString('mode', mode)
	assert.parameterTypeIsBooleanOrNil('isLeaf', isLeaf)
	
	path:assertIsFolderPath(path)
	
	local isLeafActual
	if isLeaf == nil then
		isLeafActual = true
	else
		isLeafActual = isLeaf
	end
	
	local parentSuccess = mkdirs(path:parentPath(), '0700', false)
	if not parentSuccess then
		return false
	end
	return mkdir(path, mode, isLeafActual)
end
