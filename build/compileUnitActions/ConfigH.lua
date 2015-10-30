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
	self.ensureDefinitions = {}
	
	--[[






	
	]]--
	
end


error('ENABLE_NLS is from what?')
-- TODO: Build Variant
-- Define to 1 if translation of program messages to the user's native language is requested.
function ConfigH:ENABLE_NLS(enable)
	self:_boolean('ENABLE_NLS', enable)
end





assert.globalTypeIsFunction('pairs')
function ConfigH:concatenate()
	local buffer = tabelize({})
	for defineName, defineValue in pairs(self.defines) do
		buffer:insert('function ConfigH:' .. defineName .. ' ' .. defineValue)
	end
	for defineName, defineValue in pairs(self.ensureDefinitions) do
		buffer:insert('#ifndef ' .. defineValue)
		buffer:insert('# define ' .. defineValue .. ' ' .. defineValue)
		buffer:insert('#endif')
	end
	return buffer:concat('\n')
end

function ConfigH:_ensureDefinition(defineName, enable, defineValue)
	if defineValue ~= nil then
		assert.parameterTypeIsString(defineValue)
	end
	self.ensureDefinitions[defineName] = defineValue
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

function ConfigH:_defineIfMissing(defineName, enable, defineValue)
	if enable then
		self:_undefine(defineName)
	else
		self.defines[defineName] = defineValue
	end
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
function ConfigH:_quotedNonEmptyString(defineName, value)
	if constant == nil then
		self:_undefine(defineName)
	else
		assert.parameterTypeIsString(value)
		if character:len() == 0 then
			exception.throw("The %s define can not be empty", defineName)
		end
		self.defines[defineName] = "'" .. command "'"
	end	
end

local enumerationClassParentModulePrefix
if parentModuleName == '' then
	enumerationClassParentModulePrefix = ''
else
	enumerationClassParentModulePrefix = parentModuleName .. '.'
end
function ConfigH:_enumeration(defineName, constant)
	if constant == nil then
		self:_undefine(defineName)
	else
		local enumerationClass = require(enumerationClassParentModulePrefix .. defineName)
		assert.parameterTypeIsInstanceOf(constant, enumerationClass)
		self.defines[defineName] = constant.value
	end
end



-- Name of package
function ConfigH:PACKAGE(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the address where bug reports for this package should be sent.
function ConfigH:PACKAGE_BUGREPORT(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the full name of this package.
function ConfigH:PACKAGE_NAME(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the full name and version of this package.
function ConfigH:PACKAGE_STRING(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the one symbol short name of this package.
function ConfigH:PACKAGE_TARNAME(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the home page for this package.
function ConfigH:PACKAGE_URL(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the version of this package.
function ConfigH:PACKAGE_VERSION(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Version number of package
function ConfigH:VERSION(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end




-- Define to 1 if the `closedir' function returns void instead of `int'.
function ConfigH:CLOSEDIR_VOID(enable)
	self:_boolean('CLOSEDIR_VOID', enable)
end

-- Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP systems. This function is required for `alloca.c' support on those systems.
function ConfigH:CRAY_STACKSEG_END(constant)
	self:_enumeration('CRAY_STACKSEG_END', constant)
end

-- Define to 1 if using `alloca.c'.
function ConfigH:C_ALLOCA(enable)
	self:_boolean('C_ALLOCA', enable)
end

-- Define to 1 if using `getloadavg.c'.
function ConfigH:C_GETLOADAVG(enable)
	self:_boolean('C_GETLOADAVG', enable)
end

-- Define to 1 for DGUX with <sys/dg_sys_info.h>.
function ConfigH:DGUX(enable)
	self:_boolean('DGUX', enable)
end

-- Define to 1 if the `getloadavg' function needs to be run setuid or setgid..
function ConfigH:GETLOADAVG_PRIVILEGED(enable)
	self:_boolean('GETLOADAVG_PRIVILEGED', enable)
end

-- Define to 1 if you have `alloca', as a function or macro.
function ConfigH:HAVE_ALLOCA(enable)
	self:_boolean('HAVE_ALLOCA', enable)
end

-- Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
function ConfigH:HAVE_ALLOCA_H(enable)
	self:_boolean('HAVE_ALLOCA_H', enable)
end

-- Define to 1 if you have the `atexit' function.
function ConfigH:HAVE_ATEXIT(enable)
	self:_boolean('HAVE_ATEXIT', enable)
end

-- Define to 1 if you have the MacOS X function CFLocaleCopyCurrent in the CoreFoundation framework.
function ConfigH:HAVE_CFLOCALECOPYCURRENT(enable)
	self:_boolean('HAVE_CFLOCALECOPYCURRENT', enable)
end

-- Define to 1 if you have the MacOS X function CFPreferencesCopyAppValue in the CoreFoundation framework.
function ConfigH:HAVE_CFPREFERENCESCOPYAPPVALUE(enable)
	self:_boolean('HAVE_CFPREFERENCESCOPYAPPVALUE', enable)
end

-- Define to 1 if you have the clock_gettime function.
function ConfigH:HAVE_CLOCK_GETTIME(enable)
	self:_boolean('HAVE_CLOCK_GETTIME', enable)
end

-- Define if the GNU dcgettext() function is already present or preinstalled.
function ConfigH:HAVE_DCGETTEXT(enable)
	self:_boolean('HAVE_DCGETTEXT', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `bsd_signal', and to 0 if you don't.
function ConfigH:HAVE_DECL_BSD_SIGNAL(enable)
	self:_oneOrZero('HAVE_DECL_BSD_SIGNAL', enable)
end

-- Define to 1 if you have the <dirent.h> header file, and it defines `DIR'.
function ConfigH:HAVE_DIRENT_H(enable)
	self:_oneOrZero('HAVE_DIRENT_H', enable)
end

-- Define to 1 if you have the `dup' function.
function ConfigH:HAVE_DUP(enable)
	self:_boolean('HAVE_DUP', enable)
end

-- Define to 1 if you have the `dup2' function.
function ConfigH:HAVE_DUP2(enable)
	self:_boolean('HAVE_DUP2', enable)
end

-- Define to 1 if you have the <fcntl.h> header file.
function ConfigH:HAVE_FCNTL_H(enable)
	self:_boolean('HAVE_FCNTL_H', enable)
end

-- Define to 1 if you have the `fdopen' function.
function ConfigH:HAVE_FDOPEN(enable)
	self:_boolean('HAVE_FDOPEN', enable)
end

-- Define to 1 if you have the `fileno' function.
function ConfigH:HAVE_FILENO(enable)
	self:_boolean('HAVE_FILENO', enable)
end

-- Define to 1 if you have the `getcwd' function.
function ConfigH:HAVE_GETCWD(enable)
	self:_boolean('HAVE_GETCWD', enable)
end

-- Define to 1 if you have the `getgroups' function.
function ConfigH:HAVE_GETGROUPS(enable)
	self:_boolean('HAVE_GETGROUPS', enable)
end

-- Define to 1 if you have the `gethostbyname' function.
function ConfigH:HAVE_GETHOSTBYNAME(enable)
	self:_boolean('HAVE_GETHOSTBYNAME', enable)
end

-- Define to 1 if you have the `gethostname' function.
function ConfigH:HAVE_GETHOSTNAME(enable)
	self:_boolean('HAVE_GETHOSTNAME', enable)
end

-- Define to 1 if you have the `getloadavg' function.
function ConfigH:HAVE_GETLOADAVG(enable)
	self:_boolean('HAVE_GETLOADAVG', enable)
end

-- Define to 1 if you have the `getrlimit' function.
function ConfigH:HAVE_GETRLIMIT(enable)
	self:_boolean('HAVE_GETRLIMIT', enable)
end

-- Define if the GNU gettext() function is already present or preinstalled.
function ConfigH:HAVE_GETTEXT(enable)
	self:_boolean('HAVE_GETTEXT', enable)
end

-- Define if you have the iconv() function and it works.
function ConfigH:HAVE_ICONV(enable)
	self:_boolean('HAVE_ICONV', enable)
end

-- Define to 1 if you have the <inttypes.h> header file.
function ConfigH:HAVE_INTTYPES_H(enable)
	self:_boolean('HAVE_INTTYPES_H', enable)
end

-- Define to 1 if you have the `isatty' function.
function ConfigH:HAVE_ISATTY(enable)
	self:_boolean('HAVE_ISATTY', enable)
end

-- Define to 1 if you have the `dgc' library (-ldgc).
function ConfigH:HAVE_LIBDGC(enable)
	self:_boolean('HAVE_LIBDGC', enable)
end

-- Define to 1 if you have the `kstat' library (-lkstat).
function ConfigH:HAVE_LIBKSTAT(enable)
	self:_boolean('HAVE_LIBKSTAT', enable)
end

-- Define to 1 if you have the <limits.h> header file.
function ConfigH:HAVE_LIMITS_H(enable)
	self:_boolean('HAVE_LIMITS_H', enable)
end

-- Define to 1 if you have the <locale.h> header file.
function ConfigH:HAVE_LOCALE_H(enable)
	self:_boolean('HAVE_LOCALE_H', enable)
end

-- Define to 1 if you have the `lstat' function.
function ConfigH:HAVE_LSTAT(enable)
	self:_boolean('HAVE_LSTAT', enable)
end

-- Define to 1 if you have the <mach/mach.h> header file.
function ConfigH:HAVE_MACH_MACH_H(enable)
	self:_boolean('HAVE_MACH_MACH_H', enable)
end

-- Define to 1 if you have the <memory.h> header file.
function ConfigH:HAVE_MEMORY_H(enable)
	self:_boolean('HAVE_MEMORY_H', enable)
end

-- Define to 1 if you have the `mkstemp' function.
function ConfigH:HAVE_MKSTEMP(enable)
	self:_boolean('HAVE_MKSTEMP', enable)
end

-- Define to 1 if you have the `mktemp' function.
function ConfigH:HAVE_MKTEMP(enable)
	self:_boolean('HAVE_MKTEMP', enable)
end

-- Define to 1 if you have the <ndir.h> header file, and it defines `DIR'.
function ConfigH:HAVE_NDIR_H(enable)
	self:_boolean('HAVE_NDIR_H', enable)
end

-- Define to 1 if you have the <nlist.h> header file.
function ConfigH:HAVE_NLIST_H(enable)
	self:_boolean('HAVE_NLIST_H', enable)
end

-- Define to 1 if you have the `pipe' function.
function ConfigH:HAVE_PIPE(enable)
	self:_boolean('HAVE_PIPE', enable)
end

-- Define to 1 if you have the `pstat_getdynamic' function.
function ConfigH:HAVE_PSTAT_GETDYNAMIC(enable)
	self:_boolean('HAVE_PSTAT_GETDYNAMIC', enable)
end

-- Define to 1 if you have the `readlink' function.
function ConfigH:HAVE_READLINK(enable)
	self:_boolean('HAVE_READLINK', enable)
end

-- Define to 1 if you have the `realpath' function.
function ConfigH:HAVE_REALPATH(enable)
	self:_boolean('HAVE_REALPATH', enable)
end

-- Define to 1 if you have the `setegid' function.
function ConfigH:HAVE_SETEGID(enable)
	self:_boolean('HAVE_SETEGID', enable)
end

-- Define to 1 if you have the `seteuid' function.
function ConfigH:HAVE_SETEUID(enable)
	self:_boolean('HAVE_SETEUID', enable)
end

-- Define to 1 if you have the `setlinebuf' function.
function ConfigH:HAVE_SETLINEBUF(enable)
	self:_boolean('HAVE_SETLINEBUF', enable)
end

-- Define to 1 if you have the `setlocale' function.
function ConfigH:HAVE_SETLOCALE(enable)
	self:_boolean('HAVE_SETLOCALE', enable)
end

-- Define to 1 if you have the `setregid' function.
function ConfigH:HAVE_SETREGID(enable)
	self:_boolean('HAVE_SETREGID', enable)
end

-- Define to 1 if you have the `setreuid' function.
function ConfigH:HAVE_SETREUID(enable)
	self:_boolean('HAVE_SETREUID', enable)
end

-- Define to 1 if you have the `setrlimit' function.
function ConfigH:HAVE_SETRLIMIT(enable)
	self:_boolean('HAVE_SETRLIMIT', enable)
end

-- Define to 1 if you have the `setvbuf' function.
function ConfigH:HAVE_SETVBUF(enable)
	self:_boolean('HAVE_SETVBUF', enable)
end

-- Define to 1 if you have the `sigaction' function.
function ConfigH:HAVE_SIGACTION(enable)
	self:_boolean('HAVE_SIGACTION', enable)
end

-- Define to 1 if you have the `sigsetmask' function.
function ConfigH:HAVE_SIGSETMASK(enable)
	self:_boolean('HAVE_SIGSETMASK', enable)
end

-- Define to 1 if you have the `socket' function.
function ConfigH:HAVE_SOCKET(enable)
	self:_boolean('HAVE_SOCKET', enable)
end

-- Define to 1 if you have the <stdint.h> header file.
function ConfigH:HAVE_STDINT_H(enable)
	self:_boolean('HAVE_STDINT_H', enable)
end

-- Define to 1 if you have the <stdlib.h> header file.
function ConfigH:HAVE_STDLIB_H(enable)
	self:_boolean('HAVE_STDLIB_H', enable)
end

-- Define to 1 if you have the `strcasecmp' function.
function ConfigH:HAVE_STRCASECMP(enable)
	self:_boolean('HAVE_STRCASECMP', enable)
end

-- Define to 1 if you have the `strcmpi' function.
function ConfigH:HAVE_STRCMPI(enable)
	self:_boolean('HAVE_STRCMPI', enable)
end

-- Define to 1 if you have the `strcoll' function and it is properly defined.
function ConfigH:HAVE_STRCOLL(enable)
	self:_boolean('HAVE_STRCOLL', enable)
end

-- Define to 1 if you have the `strdup' function.
function ConfigH:HAVE_STRDUP(enable)
	self:_boolean('HAVE_STRDUP', enable)
end

-- Define to 1 if you have the `strerror' function.
function ConfigH:HAVE_STRERROR(enable)
	self:_boolean('HAVE_STRERROR', enable)
end

-- Define to 1 if you have the `stricmp' function.
function ConfigH:HAVE_STRICMP(enable)
	self:_boolean('HAVE_STRICMP', enable)
end

-- Define to 1 if you have the <strings.h> header file.
function ConfigH:HAVE_STRINGS_H(enable)
	self:_boolean('HAVE_STRINGS_H', enable)
end

-- Define to 1 if you have the <string.h> header file.
function ConfigH:HAVE_STRING_H(enable)
	self:_boolean('HAVE_STRING_H', enable)
end

-- Define to 1 if you have the `strncasecmp' function.
function ConfigH:HAVE_STRNCASECMP(enable)
	self:_boolean('HAVE_STRNCASECMP', enable)
end

-- Define to 1 if you have the `strncmpi' function.
function ConfigH:HAVE_STRNCMPI(enable)
	self:_boolean('HAVE_STRNCMPI', enable)
end

-- Define to 1 if you have the `strndup' function.
function ConfigH:HAVE_STRNDUP(enable)
	self:_boolean('HAVE_STRNDUP', enable)
end

-- Define to 1 if you have the `strnicmp' function.
function ConfigH:HAVE_STRNICMP(enable)
	self:_boolean('HAVE_STRNICMP', enable)
end

-- Define to 1 if you have the `strsignal' function.
function ConfigH:HAVE_STRSIGNAL(enable)
	self:_boolean('HAVE_STRSIGNAL', enable)
end

-- Define to 1 if `n_un.n_name' is a member of `struct nlist'.
function ConfigH:HAVE_STRUCT_NLIST_N_UN_N_NAME(enable)
	self:_boolean('HAVE_STRUCT_NLIST_N_UN_N_NAME', enable)
end

-- Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
function ConfigH:HAVE_SYS_DIR_H(enable)
	self:_boolean('HAVE_SYS_DIR_H', enable)
end

-- Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
function ConfigH:HAVE_SYS_NDIR_H(enable)
	self:_boolean('HAVE_SYS_NDIR_H', enable)
end

-- Define to 1 if you have the <sys/param.h> header file.
function ConfigH:HAVE_SYS_PARAM_H(enable)
	self:_boolean('HAVE_SYS_PARAM_H', enable)
end

-- Define to 1 if you have the <sys/resource.h> header file.
function ConfigH:HAVE_SYS_RESOURCE_H(enable)
	self:_boolean('HAVE_SYS_RESOURCE_H', enable)
end

-- Define to 1 if you have the <sys/stat.h> header file.
function ConfigH:HAVE_SYS_STAT_H(enable)
	self:_boolean('HAVE_SYS_STAT_H', enable)
end

-- Define to 1 if you have the <sys/timeb.h> header file.
function ConfigH:HAVE_SYS_TIMEB_H(enable)
	self:_boolean('HAVE_SYS_TIMEB_H', enable)
end

-- Define to 1 if you have the <sys/time.h> header file.
function ConfigH:HAVE_SYS_TIME_H(enable)
	self:_boolean('HAVE_SYS_TIME_H', enable)
end

-- Define to 1 if you have the <sys/types.h> header file.
function ConfigH:HAVE_SYS_TYPES_H(enable)
	self:_boolean('HAVE_SYS_TYPES_H', enable)
end

-- Define to 1 if you have the <sys/wait.h> header file.
function ConfigH:HAVE_SYS_WAIT_H(enable)
	self:_boolean('HAVE_SYS_WAIT_H', enable)
end

-- Define to 1 if you have the `ttyname' function.
function ConfigH:HAVE_TTYNAME(enable)
	self:_boolean('HAVE_TTYNAME', enable)
end

-- Define to 1 if you have the <unistd.h> header file.
function ConfigH:HAVE_UNISTD_H(enable)
	self:_boolean('HAVE_UNISTD_H', enable)
end

-- Define to 1 if you have the `wait3' function.
function ConfigH:HAVE_WAIT3(enable)
	self:_boolean('HAVE_WAIT3', enable)
end

-- Define to 1 if you have the `waitpid' function.
function ConfigH:HAVE_WAITPID(enable)
	self:_boolean('HAVE_WAITPID', enable)
end

-- Define to 1 if your `struct nlist' has an `n_un' member. Obsolete, depend on `HAVE_STRUCT_NLIST_N_UN_N_NAME
function ConfigH:NLIST_NAME_UNION(enable)
	self:_boolean('NLIST_NAME_UNION', enable)
end

-- Mandatory
-- Define to the character that separates directories in PATH.
assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
function ConfigH:PATH_SEPARATOR_CHAR(character)
	assert.parameterTypeIsString(character)
	if character:len() ~= 1 then
		exception.throw("The path separator character must be exactly one character, it can not be '%s'", character)
	end
	
	self.defines.PATH_SEPARATOR_CHAR = character
end

-- Mandatory
-- Define as the return type of signal handlers (`int' or `void').
function ConfigH:RETSIGTYPE(constant)
	self:_enumeration('RETSIGTYPE', constant)
end

-- If using the C implementation of alloca, define if you know the direction of stack growth for your system; otherwise it will be automatically deduced at runtime.
function ConfigH:STACK_DIRECTION(constant)
	self:_enumeration('STACK_DIRECTION', constant)
end

-- Define to 1 if the `S_IS*' macros in <sys/stat.h> do not work properly.
function ConfigH:STAT_MACROS_BROKEN(enable)
	self:_boolean('STAT_MACROS_BROKEN', enable)
end

-- Define to 1 if you have the ANSI C header files.
function ConfigH:STDC_HEADERS(enable)
	self:_boolean('STDC_HEADERS', enable)
end

-- Define if struct stat contains a nanoseconds field
function ConfigH:ST_MTIM_NSEC(constant)
	self:_enumeration('ST_MTIM_NSEC', constant)
end

-- Define to 1 on System V Release 4.
function ConfigH:SVR4(enable)
	self:_boolean('SVR4', enable)
end

-- Define to 1 if you can safely include both <sys/time.h> and <time.h>.
function ConfigH:TIME_WITH_SYS_TIME(enable)
	self:_boolean('TIME_WITH_SYS_TIME', enable)
end

-- Define to 1 for Encore UMAX.
function ConfigH:UMAX(enable)
	self:_boolean('UMAX', enable)
end

-- Define to 1 for Encore UMAX 4.3 that has <inq_status/cpustats.h> instead of <sys/cpustats.h>.
function ConfigH:UMAX4_3(enable)
	self:_boolean('UMAX4_3', enable)
end



-- AC_SYS_LARGEFILE  (Large file support; Irix 6.2+ CC needs '-n32')
-- Enable large inode numbers on Mac OS X 10.5.
function ConfigH:_DARWIN_USE_64_BIT_INODE(enable)
	self:_ensureDefinition('_DARWIN_USE_64_BIT_INODE', enable, '1')
end

-- AC_SYS_LARGEFILE
-- Number of bits in a file offset, on hosts where this is settable.
function ConfigH:_FILE_OFFSET_BITS(enable)
	self:_boolean('_FILE_OFFSET_BITS', enable)
end

-- AC_SYS_LARGEFILE
-- Define for large files, on AIX-style hosts.
function ConfigH:_LARGE_FILES(enable)
	self:_boolean('_LARGE_FILES', enable)
end



-- AC_USE_SYSTEM_EXTENSIONS
-- Define to 2 if the system does not provide POSIX.1 features except with this defined.
-- MINIX only
function ConfigH:_POSIX_1_SOURCE(enable)
	if enable then
		self.definitions['_POSIX_1_SOURCE'] = '2'
	else
		self:_undefine('_POSIX_1_SOURCE')
	end
end

-- AC_USE_SYSTEM_EXTENSIONS
-- Define to 1 if you need to in order for `stat' and other things to work.
-- MINIX only
function ConfigH:_POSIX_SOURCE(enable)
	self:_boolean('_POSIX_SOURCE', enable)
end

-- Define to 1 if on MINIX.
-- MINIX only
function ConfigH:_MINIX(enable)
	self:_boolean('_MINIX', enable)
end

-- Enable extensions on AIX 3, Interix.
function ConfigH:_ALL_SOURCE(enable)
	self:_ensureDefinition('_ALL_SOURCE', enable, '1')
end

-- Enable GNU extensions on systems that have them. 
function ConfigH:_GNU_SOURCE(enable)
	self:_ensureDefinition('_GNU_SOURCE', enable, '1')
end

-- Enable threading extensions on Solaris.
function ConfigH:_POSIX_PTHREAD_SEMANTICS(enable)
	self:_ensureDefinition('_POSIX_PTHREAD_SEMANTICS', enable, '1')
end

-- Enable extensions on HP NonStop.
function ConfigH:_TANDEM_SOURCE(enable)
	self:_ensureDefinition('_TANDEM_SOURCE', enable, '1')
end

-- Enable general extensions on Solaris.
function ConfigH:_TANDEM_SOURCE(enable)
	self:_ensureDefinition('__EXTENSIONS__', enable, '1')
end

-- Define to empty if `const' does not conform to ANSI C.
function ConfigH:const(enable)
	self:_defineIfMissing('const', enable, '')
end

-- Define to `int' if <sys/types.h> doesn't define.
function ConfigH:uid_t(enable)
	self:_defineIfMissing('uid_t', enable, 'int')
end
	
-- Define to `int' if <sys/types.h> doesn't define.
function ConfigH:gid_t(enable)
	self:_defineIfMissing('gid_t', enable, 'int')
end


-- Mac Laptop OS X 10.9
local ConfigHMacOsX = ConfigH:new()
ConfigHMacOsX:HAVE_ALLOCA(true)
ConfigHMacOsX:HAVE_ALLOCA_H(true)
ConfigHMacOsX:HAVE_ATEXIT(true)
ConfigHMacOsX:HAVE_CFLOCALECOPYCURRENT(true)
ConfigHMacOsX:HAVE_CFPREFERENCESCOPYAPPVALUE(true)
ConfigHMacOsX:HAVE_DECL_BSD_SIGNAL(true)
ConfigHMacOsX:HAVE_DIRENT_H(true)
ConfigHMacOSX:HAVE_DUP(true)
ConfigHMacOSX:HAVE_DUP2(true)
ConfigHMacOSX:HAVE_FDOPEN(true)
ConfigHMacOSX:HAVE_FILENO(true)
ConfigHMacOSX:HAVE_GETCWD(true)
ConfigHMacOSX:HAVE_GETGROUPS(true)
ConfigHMacOSX:HAVE_GETLOADAVG(true)
ConfigHMacOSX:HAVE_GETRLIMIT(true)
ConfigHMacOSX:HAVE_FCNTL_H(true)
ConfigHMacOSX:HAVE_INTTYPES_H(true)
ConfigHMacOSX:HAVE_ISATTY(true)
ConfigHMacOSX:HAVE_LIMITS_H(true)
ConfigHMacOSX:HAVE_LOCALE_H(true)
ConfigHMacOSX:HAVE_LSTAT(true)
ConfigHMacOSX:HAVE_MEMORY_H(true)
ConfigHMacOSX:HAVE_MKSTEMP(true)
ConfigHMacOSX:HAVE_MKTEMP(true)
ConfigHMacOSX:HAVE_PIPE(true)
ConfigHMacOSX:HAVE_READLINK(true)
ConfigHMacOSX:HAVE_REALPATH(true)
ConfigHMacOSX:HAVE_SETEGID(true)
ConfigHMacOSX:HAVE_SETEUID(true)
ConfigHMacOSX:HAVE_SETLINEBUF(true)
ConfigHMacOSX:HAVE_SETREGID(true)
ConfigHMacOSX:HAVE_SETREUID(true)
ConfigHMacOSX:HAVE_SETRLIMIT(true)
ConfigHMacOSX:HAVE_SETVBUF(true)
ConfigHMacOSX:HAVE_SIGACTION(true)
ConfigHMacOSX:HAVE_SIGSETMASK(true)
ConfigHMacOSX:HAVE_STDINT_H(true)
ConfigHMacOSX:HAVE_STDLIB_H(true)
ConfigHMacOSX:HAVE_STRCASECMP(true)
ConfigHMacOSX:HAVE_STRCOLL(true)
ConfigHMacOSX:HAVE_STRDUP(true)
ConfigHMacOSX:HAVE_STRERROR(true)
ConfigHMacOSX:HAVE_STRINGS_H(true)
ConfigHMacOSX:HAVE_STRING_H(true)
ConfigHMacOSX:HAVE_STRNCASECMP(true)
ConfigHMacOSX:HAVE_STRNDUP(true)
ConfigHMacOSX:HAVE_STRSIGNAL(true)
ConfigHMacOSX:HAVE_SYS_PARAM_H(true)
ConfigHMacOSX:HAVE_SYS_RESOURCE_H(true)
ConfigHMacOSX:HAVE_SYS_STAT_H(true)
ConfigHMacOSX:HAVE_SYS_TIMEB_H(true)
ConfigHMacOSX:HAVE_SYS_TIME_H(true)
ConfigHMacOSX:HAVE_SYS_TYPES_H(true)
ConfigHMacOSX:HAVE_SYS_WAIT_H(true)
ConfigHMacOSX:HAVE_TTYNAME(true)
ConfigHMacOSX:HAVE_UNISTD_H(true)
ConfigHMacOSX:HAVE_WAIT3(true)
ConfigHMacOSX:HAVE_WAITPID(true)
ConfigHMacOSX:PATH_SEPARATOR_CHAR(':')
ConfigHMacOSX:RETSIGTYPE(requireSibling('RETSIGTYPE').void)
ConfigHMacOSX:ST_MTIM_NSEC(requireSibling('ST_MTIM_NSEC')['st_mtimespec.tv_nsec'])
ConfigHMacOSX:STDC_HEADERS(true)
ConfigHMacOSX:TIME_WITH_SYS_TIME(true)
ConfigHMacOSX:_DARWIN_USE_64_BIT_INODE(true)


-- Stuff like HAVE_XXXXX_H is from AC_CHECK_HEADERS(sys/timeb.h) => HAVE_SYS_TIMEB_H
-- Although some are so common as standardised, eg AC_HEADER_* such as AC_HEADER_DIRENT
-- Likewise AC_CHECK_FUNCS
-- TODO: AC_SEARCH_LIBS


-- Make-code-specific (all were enabled on Mac OS X)

local MakeConfigHMacOSX = ConfigHMacOSX
-- Hmmm, more just MacOSX specific (bar _GNU_SOURCE)
MakeConfigHMacOSX:_ALL_SOURCE(true)
MakeConfigHMacOSX:_GNU_SOURCE(true)
MakeConfigHMacOSX:_POSIX_PTHREAD_SEMANTICS(true)
MakeConfigHMacOSX:_TANDEM_SOURCE(true)
MakeConfigHMacOSX:__EXTENSIONS__(true)



-- Embed GNU Guile support
function MakeConfigH:HAVE_GUILE(enable)
	self:_boolean('HAVE_GUILE', enable)
end

-- Define to 1 to enable job server support in GNU make.
function MakeConfigH:MAKE_JOBSERVER(enable)
	self:_boolean('MAKE_JOBSERVER', enable)
end

-- Enable only if HAVE_DECL_DLOPEN, HAVE_DECL_DLSYM, HAVE_DECL_DLERROR
-- Define to 1 to enable 'load' support in GNU make.
function MakeConfigH:MAKE_LOAD(enable)
	self:_boolean('MAKE_LOAD', enable)
end
	
-- Define to 1 to enable symbolic link timestamp checking.
function MakeConfigH:MAKE_SYMLINKS(enable)
	self:_boolean('MAKE_SYMLINKS', enable)
end

-- [detected by looking for *-*-mingw32 in $host in configure.ac]
-- Define to 1 if your system requires backslashes or drive specs in pathnames
function MakeConfigH:HAVE_DOS_PATHS(enable)
	self:_boolean('HAVE_DOS_PATHS', enable)
end

-- Use platform specific coding
function MakeConfigH:WINDOWS32(enable)
	self:_boolean('WINDOWS32', enable)
end

-- Use case insensitive file names
function MakeConfigH:HAVE_CASE_INSENSITIVE_FS(enable)
	self:_boolean('HAVE_CASE_INSENSITIVE_FS', enable)
end

-- Use high resolution file timestamps if nonzero.
function MakeConfigH:FILE_TIMESTAMP_HI_RES(enable)
	self:_boolean('FILE_TIMESTAMP_HI_RES', enable)
end

-- Define to 1 if you have a standard gettimeofday function
function MakeConfigH:HAVE_GETTIMEOFDAY(enable)
	self:_boolean('HAVE_GETTIMEOFDAY', enable)
end

-- Define to 1 if struct nlist.n_name is a pointer rather than an array.
function MakeConfigH:NLIST_STRUCT(enable)
	self:_boolean('NLIST_STRUCT', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `dlerror', and to 0 if you don't.
function MakeConfigH:HAVE_DECL_DLERROR(enable)
	self:_oneOrZero('HAVE_DECL_DLERROR', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `dlopen', and to 0 if you don't.
function MakeConfigH:HAVE_DECL_DLOPEN(enable)
	self:_oneOrZero('HAVE_DECL_DLOPEN', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `dlsym', and to 0 if you don't.
function MakeConfigH:HAVE_DECL_DLSYM(enable)
	self:_oneOrZero('HAVE_DECL_DLSYM', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `sys_siglist', and to 0 if you don't.
function MakeConfigH:HAVE_DECL_SYS_SIGLIST(enable)
	self:_oneOrZero('HAVE_DECL_SYS_SIGLIST', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `_sys_siglist', and to 0 if you don't.
function MakeConfigH:HAVE_DECL__SYS_SIGLIST(enable)
	self:_oneOrZero('HAVE_DECL__SYS_SIGLIST', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `__sys_siglist', and to 0 if you don't.
function MakeConfigH:HAVE_DECL___SYS_SIGLIST(enable)
	self:_oneOrZero('HAVE_DECL___SYS_SIGLIST', enable)
end

-- Define to 1 if you have the 'union wait' type in <sys/wait.h>.
function MakeConfigH:HAVE_UNION_WAIT(enable)
	self:_boolean('HAVE_UNION_WAIT', enable)
end

-- Define to 1 if <signal.h> defines the SA_RESTART constant.
function MakeConfigH:HAVE_SA_RESTART(enable)
	self:_boolean('HAVE_SA_RESTART', enable)
end

-- Mandatory
-- Define to the name of the SCCS 'get' command.
function MakeConfigH:SCCS_GET(command)
	self:_quotedNonEmptyString('SCCS_GET', command)
end

-- Define to 1 if the SCCS 'get' command understands the '-G<file>' option.
function MakeConfigH:SCCS_GET_MINUS_G(enable)
	self:_boolean('SCCS_GET_MINUS_G', enable)
end
	
-- Define to `int' if <sys/types.h> does not define.
function MakeConfigH:pid_t(enable)
	self:_defineIfMissing('pid_t', enable, 'int')
end

-- Define to `unsigned int' if <sys/types.h> does not define.
function MakeConfigH:size_t(enable)
	self:_defineIfMissing('size_t', enable, 'unsigned int')
end

-- NOTE: There is a better test than this in autoconf AC_TYPE_UINTMAX_T
-- Define uintmax_t if not defined in <stdint.h> or <inttypes.h>.
function MakeConfigH:uintmax_t(enable)
	self:_defineIfMissing('uintmax_t', enable, 'unsigned long long')
end

function ConfigH:WITH_DMALLOC(enable)
	self:_boolean('WITH_DMALLOC', enable)
end

-- Build host information.
function ConfigH:MAKE_HOST(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Make extra-checks
MakeConfigHMacOSX:FILE_TIMESTAMP_HI_RES(true)
MakeConfigHMacOSX:HAVE_GETTIMEOFDAY(true)
MakeConfigHMacOSX:HAVE_DECL_SYS_SIGLIST(true)
MakeConfigHMacOSX:HAVE_SA_RESTART(true)
MakeConfigHMacOSX:MAKE_JOBSERVER(true) -- OS/2 or MingGW or HAVE_PIPE && HAVE_SIGACTION && HAVE_SA_RESTART && ?WAIT_NOHANG?
MakeConfigHMacOSX:HAVE_DECL_DLERROR(true)
MakeConfigHMacOSX:HAVE_DECL_DLOPEN(true)
MakeConfigHMacOSX:HAVE_DECL_DLSYM(true)
MakeConfigHMacOSX:MAKE_LOAD(true) -- HAVE_DECL_DLERROR && HAVE_DECL_DLOPEN && HAVE_DECL_DLSYM
MakeConfigHMacOSX:MAKE_SYMLINKS(true)  -- HAVE_LSTAT and HAVE_READLINK
MakeConfigHMacOSX:MAKE_HOST("x86_64-apple-darwin13.4.0")  -- Toolchain target triple
MakeConfigH:SCCS_GET('get')  -- Harcoded search for /usr/sccs/get, oh my... probably ought to set this to 'false'; used in default.c as one of the default make variables. Make really is disgusting.

local organisation = 'GNU'
local name = 'make'
local version = '4.1'

-- Name of package
MakeConfigH:PACKAGE(name)

-- Define to the address where bug reports for this package should be sent.
MakeConfigH:PACKAGE_BUGREPORT('bug-' .. name .. '@gnu.org')

-- Define to the full name of this package.
MakeConfigH:PACKAGE_NAME(organisation .. ' ' .. name)

-- Define to the full name and version of this package.
MakeConfigH:PACKAGE_STRING(organisation .. ' ' .. name .. ' ' .. version)

-- Define to the one symbol short name of this package.
MakeConfigH:PACKAGE_TARNAME(name)

-- Define to the home page for this package.
MakeConfigH:PACKAGE_URL('http://www.gnu.org/software/' .. name .. '/')

-- Define to the version of this package.
MakeConfigH:PACKAGE_VERSION(version)

-- Version number of package
MakeConfigH:VERSION(version)





