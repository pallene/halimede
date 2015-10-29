--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local class = require('middleclass')
local tabelize = require('halimede.table.tabelize').tabelize


local ConfigH = class('ConfigH')

-- In many ways, large parts of this are per toolchain
function ConfigH:initialize()
	self.defines = {}
	--[[


	-- Build host information.
	function Config:MAKE_HOST "x86_64-apple-darwin13.4.0"
	-- Define to 1 to enable job server support in GNU make.
	function Config:MAKE_JOBSERVER 1
	-- Define to 1 to enable 'load' support in GNU make.
	function Config:MAKE_LOAD 1
	-- Define to 1 to enable symbolic link timestamp checking.
	function Config:MAKE_SYMLINKS 1
	-- Name of package
	function Config:PACKAGE "make"
	-- Define to the address where bug reports for this package should be sent.
	function Config:PACKAGE_BUGREPORT "bug-make@gnu.org"
	-- Define to the full name of this package.
	function Config:PACKAGE_NAME "GNU make"
	-- Define to the full name and version of this package.
	function Config:PACKAGE_STRING "GNU make 4.1"
	-- Define to the one symbol short name of this package.
	function Config:PACKAGE_TARNAME "make"
	-- Define to the home page for this package.
	function Config:PACKAGE_URL "http://www.gnu.org/software/make/"
	-- Define to the version of this package.
	function Config:PACKAGE_VERSION "4.1"
	-- Version number of package
	function Config:VERSION "4.1"
	
	





	-- Define to 1 if you have the <dirent.h> header file, and it defines `DIR'.
	function Config:HAVE_DIRENT_H 1

	-- Use platform specific coding
	function Config:HAVE_DOS_PATHS

	-- Define to 1 if you have the `dup' function.
	function Config:HAVE_DUP 1

	-- Define to 1 if you have the `dup2' function.
	function Config:HAVE_DUP2 1

	-- Define to 1 if you have the <fcntl.h> header file.
	function Config:HAVE_FCNTL_H 1

	-- Define to 1 if you have the `fdopen' function.
	function Config:HAVE_FDOPEN 1

	-- Define to 1 if you have the `fileno' function.
	function Config:HAVE_FILENO 1

	-- Define to 1 if you have the `getcwd' function.
	function Config:HAVE_GETCWD 1

	-- Define to 1 if you have the `getgroups' function.
	function Config:HAVE_GETGROUPS 1

	-- Define to 1 if you have the `gethostbyname' function.
	function Config:HAVE_GETHOSTBYNAME

	-- Define to 1 if you have the `gethostname' function.
	function Config:HAVE_GETHOSTNAME

	-- Define to 1 if you have the `getloadavg' function.
	function Config:HAVE_GETLOADAVG 1

	-- Define to 1 if you have the `getrlimit' function.
	function Config:HAVE_GETRLIMIT 1

	-- Define if the GNU gettext() function is already present or preinstalled.
	function Config:HAVE_GETTEXT

	-- Define to 1 if you have a standard gettimeofday function
	function Config:HAVE_GETTIMEOFDAY 1

	-- Embed GNU Guile support
	function Config:HAVE_GUILE

	-- Define if you have the iconv() function and it works.
	function Config:HAVE_ICONV

	-- Define to 1 if you have the <inttypes.h> header file.
	function Config:HAVE_INTTYPES_H 1

	-- Define to 1 if you have the `isatty' function.
	function Config:HAVE_ISATTY 1

	-- Define to 1 if you have the `dgc' library (-ldgc).
	function Config:HAVE_LIBDGC

	-- Define to 1 if you have the `kstat' library (-lkstat).
	function Config:HAVE_LIBKSTAT

	-- Define to 1 if you have the <limits.h> header file.
	function Config:HAVE_LIMITS_H 1

	-- Define to 1 if you have the <locale.h> header file.
	function Config:HAVE_LOCALE_H 1

	-- Define to 1 if you have the `lstat' function.
	function Config:HAVE_LSTAT 1

	-- Define to 1 if you have the <mach/mach.h> header file.
	function Config:HAVE_MACH_MACH_H

	-- Define to 1 if you have the <memory.h> header file.
	function Config:HAVE_MEMORY_H 1

	-- Define to 1 if you have the `mkstemp' function.
	function Config:HAVE_MKSTEMP 1

	-- Define to 1 if you have the `mktemp' function.
	function Config:HAVE_MKTEMP 1

	-- Define to 1 if you have the <ndir.h> header file, and it defines `DIR'.
	function Config:HAVE_NDIR_H

	-- Define to 1 if you have the <nlist.h> header file.
	function Config:HAVE_NLIST_H

	-- Define to 1 if you have the `pipe' function.
	function Config:HAVE_PIPE 1

	-- Define to 1 if you have the `pstat_getdynamic' function.
	function Config:HAVE_PSTAT_GETDYNAMIC

	-- Define to 1 if you have the `readlink' function.
	function Config:HAVE_READLINK 1

	-- Define to 1 if you have the `realpath' function.
	function Config:HAVE_REALPATH 1

	-- Define to 1 if <signal.h> defines the SA_RESTART constant.
	function Config:HAVE_SA_RESTART 1

	-- Define to 1 if you have the `setegid' function.
	function Config:HAVE_SETEGID 1

	-- Define to 1 if you have the `seteuid' function.
	function Config:HAVE_SETEUID 1

	-- Define to 1 if you have the `setlinebuf' function.
	function Config:HAVE_SETLINEBUF 1

	-- Define to 1 if you have the `setlocale' function.
	function Config:HAVE_SETLOCALE

	-- Define to 1 if you have the `setregid' function.
	function Config:HAVE_SETREGID 1

	-- Define to 1 if you have the `setreuid' function.
	function Config:HAVE_SETREUID 1

	-- Define to 1 if you have the `setrlimit' function.
	function Config:HAVE_SETRLIMIT 1

	-- Define to 1 if you have the `setvbuf' function.
	function Config:HAVE_SETVBUF 1

	-- Define to 1 if you have the `sigaction' function.
	function Config:HAVE_SIGACTION 1

	-- Define to 1 if you have the `sigsetmask' function.
	function Config:HAVE_SIGSETMASK 1

	-- Define to 1 if you have the `socket' function.
	function Config:HAVE_SOCKET

	-- Define to 1 if you have the <stdint.h> header file.
	function Config:HAVE_STDINT_H 1

	-- Define to 1 if you have the <stdlib.h> header file.
	function Config:HAVE_STDLIB_H 1

	-- Define to 1 if you have the `strcasecmp' function.
	function Config:HAVE_STRCASECMP 1

	-- Define to 1 if you have the `strcmpi' function.
	function Config:HAVE_STRCMPI

	-- Define to 1 if you have the `strcoll' function and it is properly defined.
	function Config:HAVE_STRCOLL 1

	-- Define to 1 if you have the `strdup' function.
	function Config:HAVE_STRDUP 1

	-- Define to 1 if you have the `strerror' function.
	function Config:HAVE_STRERROR 1

	-- Define to 1 if you have the `stricmp' function.
	function Config:HAVE_STRICMP

	-- Define to 1 if you have the <strings.h> header file.
	function Config:HAVE_STRINGS_H 1

	-- Define to 1 if you have the <string.h> header file.
	function Config:HAVE_STRING_H 1

	-- Define to 1 if you have the `strncasecmp' function.
	function Config:HAVE_STRNCASECMP 1

	-- Define to 1 if you have the `strncmpi' function.
	function Config:HAVE_STRNCMPI

	-- Define to 1 if you have the `strndup' function.
	function Config:HAVE_STRNDUP 1

	-- Define to 1 if you have the `strnicmp' function.
	function Config:HAVE_STRNICMP

	-- Define to 1 if you have the `strsignal' function.
	function Config:HAVE_STRSIGNAL 1

	-- Define to 1 if `n_un.n_name' is a member of `struct nlist'.
	function Config:HAVE_STRUCT_NLIST_N_UN_N_NAME

	-- Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
	function Config:HAVE_SYS_DIR_H

	-- Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
	function Config:HAVE_SYS_NDIR_H

	-- Define to 1 if you have the <sys/param.h> header file.
	function Config:HAVE_SYS_PARAM_H 1

	-- Define to 1 if you have the <sys/resource.h> header file.
	function Config:HAVE_SYS_RESOURCE_H 1

	-- Define to 1 if you have the <sys/stat.h> header file.
	function Config:HAVE_SYS_STAT_H 1

	-- Define to 1 if you have the <sys/timeb.h> header file.
	function Config:HAVE_SYS_TIMEB_H 1

	-- Define to 1 if you have the <sys/time.h> header file.
	function Config:HAVE_SYS_TIME_H 1

	-- Define to 1 if you have the <sys/types.h> header file.
	function Config:HAVE_SYS_TYPES_H 1

	-- Define to 1 if you have the <sys/wait.h> header file.
	function Config:HAVE_SYS_WAIT_H 1

	-- Define to 1 if you have the `ttyname' function.
	function Config:HAVE_TTYNAME 1

	-- Define to 1 if you have the 'union wait' type in <sys/wait.h>.
	function Config:HAVE_UNION_WAIT

	-- Define to 1 if you have the <unistd.h> header file.
	function Config:HAVE_UNISTD_H 1

	-- Define to 1 if you have the `wait3' function.
	function Config:HAVE_WAIT3 1

	-- Define to 1 if you have the `waitpid' function.
	function Config:HAVE_WAITPID 1

	-- Define to 1 if your `struct nlist' has an `n_un' member. Obsolete, depend on `HAVE_STRUCT_NLIST_N_UN_N_NAME
	function Config:NLIST_NAME_UNION

	-- Define to 1 if struct nlist.n_name is a pointer rather than an array.
	function Config:NLIST_STRUCT

	-- Define to the character that separates directories in PATH.
	function Config:PATH_SEPARATOR_CHAR ':'

	-- Define as the return type of signal handlers (`int' or `void').
	function Config:RETSIGTYPE void

	-- Define to the name of the SCCS 'get' command.
	function Config:SCCS_GET "get"

	-- Define to 1 if the SCCS 'get' command understands the '-G<file>' option.
	function Config:SCCS_GET_MINUS_G

	-- If using the C implementation of alloca, define if you know the direction of stack growth for your system; otherwise it will be automatically deduced at runtime.
		STACK_DIRECTION > 0 => grows toward higher addresses
		STACK_DIRECTION < 0 => grows toward lower addresses
		STACK_DIRECTION = 0 => direction of growth unknown
	function Config:STACK_DIRECTION

	-- Define to 1 if the `S_IS*' macros in <sys/stat.h> do not work properly.
	function Config:STAT_MACROS_BROKEN

	-- Define to 1 if you have the ANSI C header files.
	function Config:STDC_HEADERS 1

	-- Define if struct stat contains a nanoseconds field
	function Config:ST_MTIM_NSEC st_mtimespec.tv_nsec

	-- Define to 1 on System V Release 4.
	function Config:SVR4

	-- Define to 1 if you can safely include both <sys/time.h> and <time.h>.
	function Config:TIME_WITH_SYS_TIME 1

	-- Define to 1 for Encore UMAX.
	function Config:UMAX

	-- Define to 1 for Encore UMAX 4.3 that has <inq_status/cpustats.h> instead of <sys/cpustats.h>.
	function Config:UMAX4_3

	-- Enable extensions on AIX 3, Interix. 
	#ifndef _ALL_SOURCE
	# define _ALL_SOURCE 1
	#endif
	-- Enable GNU extensions on systems that have them. 
	#ifndef _GNU_SOURCE
	# define _GNU_SOURCE 1
	#endif
	-- Enable threading extensions on Solaris. 
	#ifndef _POSIX_PTHREAD_SEMANTICS
	# define _POSIX_PTHREAD_SEMANTICS 1
	#endif
	-- Enable extensions on HP NonStop. 
	#ifndef _TANDEM_SOURCE
	# define _TANDEM_SOURCE 1
	#endif
	-- Enable general extensions on Solaris. 
	#ifndef __EXTENSIONS__
	# define __EXTENSIONS__ 1
	#endif



	-- Use platform specific coding
	function Config:WINDOWS32

	-- Define if using the dmalloc debugging malloc package
	function Config:WITH_DMALLOC

	-- Enable large inode numbers on Mac OS X 10.5. 
	#ifndef _DARWIN_USE_64_BIT_INODE
	# define _DARWIN_USE_64_BIT_INODE 1
	#endif

	-- Number of bits in a file offset, on hosts where this is settable.
	function Config:_FILE_OFFSET_BITS

	-- Define for large files, on AIX-style hosts.
	function Config:_LARGE_FILES

	-- Define to 1 if on MINIX.
	function Config:_MINIX

	-- Define to 2 if the system does not provide POSIX.1 features except with this defined.
	function Config:_POSIX_1_SOURCE

	-- Define to 1 if you need to in order for `stat' and other things to work.
	function Config:_POSIX_SOURCE

	-- Define to empty if `const' does not conform to ANSI C.
	function Config:const

	-- Define to `int' if <sys/types.h> doesn't define.
	function Config:gid_t

	-- Define to `int' if <sys/types.h> does not define.
	function Config:pid_t

	-- Define to `unsigned int' if <sys/types.h> does not define.
	function Config:size_t

	-- Define to `int' if <sys/types.h> doesn't define.
	function Config:uid_t

	-- Define uintmax_t if not defined in <stdint.h> or <inttypes.h>.
	function Config:uintmax_t
	
	]]--
	
end

function ConfigH:_undefine(defineName)
	self.defines[defineName] = nil
end

function ConfigH:_boolean(defineName, enable)
	assert.parameterTypeIsBoolean(enable)
	
	if enable then
		self.defines[defineName] = '1'
	else
		self:_undefine(defineName)
	end
end

function ConfigH:_oneOrZero(defineName, enable)
	assert.parameterTypeIsBoolean(enable)
	
	if enable then
		self.defines[defineName] = '1'
	else
		self.defines[defineName] = '0'
	end
end

-- TODO: Append these to the defines command line option
assert.globalTypeIsFunction('pairs')
function ConfigH:concatenate()
	local buffer = tabelize({})
	for defineName, defineValue in pairs(self.defines) do
		buffer:insert('function Config:' .. defineName .. ' ' .. defineValue)
	end
	return buffer:concat('\n')
end

-- Define to 1 if the `closedir' function returns void instead of `int'.
function ConfigH:CLOSEDIR_VOID(enable)
	self:_boolean(CLOSEDIR_VOID, enable)
end

local CRAY_STACKSEG_END = class('CRAY_STACKSEG_END')

function CRAY_STACKSEG_END:initialize(value)
	assert.parameterTypeIsString(value)
	
	self.value = value
end

ConfigH.static.CRAY_STACKSEG_END_values = {
	['__getb67'] = CRAY_STACKSEG_END:new('__getb67'),
	['GETB67'] = CRAY_STACKSEG_END:new('GETB67'),
	['getb67'] = CRAY_STACKSEG_END:new('getb67'),
}

-- Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP systems. This function is required for `alloca.c' support on those systems.
function ConfigH:CRAY_STACKSEG_END(constant)
	if constant == nil then
		self.defines.CRAY_STACKSEG_END = nil
	else
		assert.parameterTypeIsInstanceOf(constant, CRAY_STACKSEG_END)
		self.defines.CRAY_STACKSEG_END = constant.value
	end
end

-- Define to 1 if using `alloca.c'.
function ConfigH:C_ALLOCA(enable)
	self:_boolean(C_ALLOCA, enable)
end

-- Define to 1 if using `getloadavg.c'.
function ConfigH:C_GETLOADAVG(enable)
	self:_boolean(C_GETLOADAVG, enable)
end

-- Define to 1 for DGUX with <sys/dg_sys_info.h>.
function ConfigH:DGUX(enable)
	self:_boolean(DGUX, enable)
end

-- TODO: Might be something to override
-- Define to 1 if translation of program messages to the user's native language is requested.
function ConfigH:ENABLE_NLS(enable)
	self:_boolean(ENABLE_NLS, enable)
end

-- Use high resolution file timestamps if nonzero.
function ConfigH:FILE_TIMESTAMP_HI_RES(enable)
	self:_boolean(FILE_TIMESTAMP_HI_RES, enable)
end

-- Define to 1 if the `getloadavg' function needs to be run setuid or setgid..
function ConfigH:GETLOADAVG_PRIVILEGED(enable)
	self:_boolean(GETLOADAVG_PRIVILEGED, enable)
end

-- Define to 1 if you have `alloca', as a function or macro.
function Config:HAVE_ALLOCA(enable)
	self:_boolean(HAVE_ALLOCA, enable)
end

-- Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
function Config:HAVE_ALLOCA_H(enable)
	self:_boolean(HAVE_ALLOCA_H, enable)
end

-- Define to 1 if you have the `atexit' function.
function Config:HAVE_ATEXIT(enable)
	self:_boolean(HAVE_ATEXIT, enable)
end

-- ? MAKE SPECIFIC ?
-- Use case insensitive file names
function Config:HAVE_CASE_INSENSITIVE_FS(enable)
	self:_boolean(HAVE_CASE_INSENSITIVE_FS, enable)
end

-- Define to 1 if you have the MacOS X function CFLocaleCopyCurrent in the CoreFoundation framework.
function Config:HAVE_CFLOCALECOPYCURRENT(enable)
	self:_boolean(HAVE_CFLOCALECOPYCURRENT, enable)
end

-- Define to 1 if you have the MacOS X function CFPreferencesCopyAppValue in the CoreFoundation framework.
function Config:HAVE_CFPREFERENCESCOPYAPPVALUE(enable)
	self:_boolean(HAVE_CFPREFERENCESCOPYAPPVALUE, enable)
end

-- Define to 1 if you have the clock_gettime function.
function Config:HAVE_CLOCK_GETTIME(enable)
	self:_boolean(HAVE_CLOCK_GETTIME, enable)
end

-- Define if the GNU dcgettext() function is already present or preinstalled.
function Config:HAVE_DCGETTEXT(enable)
	self:_boolean(HAVE_DCGETTEXT, enable)
end

-- Define to 1 if you have the declaration of `bsd_signal', and to 0 if you don't.
function Config:HAVE_DECL_BSD_SIGNAL(enable)
	self:_oneOrZero(HAVE_DECL_BSD_SIGNAL, enable)
end

-- Define to 1 if you have the declaration of `dlerror', and to 0 if you don't.
function Config:HAVE_DECL_DLERROR(enable)
	self:_oneOrZero(HAVE_DECL_DLERROR, enable)
end

-- Define to 1 if you have the declaration of `dlopen', and to 0 if you don't.
function Config:HAVE_DECL_DLOPEN(enable)
	self:_oneOrZero(HAVE_DECL_DLOPEN, enable)
end

-- Define to 1 if you have the declaration of `dlsym', and to 0 if you don't.
function Config:HAVE_DECL_DLSYM(enable)
	self:_oneOrZero(HAVE_DECL_DLSYM, enable)
end

-- Define to 1 if you have the declaration of `sys_siglist', and to 0 if you don't.
function Config:HAVE_DECL_SYS_SIGLIST(enable)
	self:_oneOrZero(HAVE_DECL_SYS_SIGLIST, enable)
end

-- Define to 1 if you have the declaration of `_sys_siglist', and to 0 if you don't.
function Config:HAVE_DECL__SYS_SIGLIST(enable)
	self:_oneOrZero(HAVE_DECL__SYS_SIGLIST, enable)
end

-- Define to 1 if you have the declaration of `__sys_siglist', and to 0 if you don't.
function Config:HAVE_DECL___SYS_SIGLIST(enable)
	self:_oneOrZero(HAVE_DECL___SYS_SIGLIST, enable)
end


-- Mac Laptop
local ConfigHMacOsX = ConfigH:new()
ConfigHMacOsX:FILE_TIMESTAMP_HI_RES(true)
ConfigHMacOsX:HAVE_ALLOCA(true)
ConfigHMacOsX:HAVE_ALLOCA_H(true)
ConfigHMacOsX:HAVE_ATEXIT(true)
ConfigHMacOsX:HAVE_CFLOCALECOPYCURRENT(true)
ConfigHMacOsX:HAVE_CFPREFERENCESCOPYAPPVALUE(true)
ConfigHMacOsX:HAVE_DECL_BSD_SIGNAL(true)
ConfigHMacOsX:HAVE_DECL_DLERROR(true)
ConfigHMacOsX:HAVE_DECL_DLOPEN(true)
ConfigHMacOsX:HAVE_DECL_DLSYM(true)
ConfigHMacOsX:HAVE_DECL_SYS_SIGLIST(true)
ConfigHMacOsX:HAVE_DECL__SYS_SIGLIST(false)
ConfigHMacOsX:HAVE_DECL___SYS_SIGLIST(false)