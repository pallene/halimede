--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local Defines = require.sibling('Defines')
local ConfigHDefines = moduleclass('ConfigHDefines', Defines)

local tabelize = halimede.table.tabelize


function module:initialize()
	Defines.initialize(self)
	self.ensureDefinitions = {}
end

assert.globalTypeIsFunction('pairs')
function module:toCPreprocessorTextLines()	
	local buffer = tabelize()
	for defineName, _ in pairs(self.explicitlyUndefine) do
		buffer:insert('#undef ' .. defineName)
	end
	for defineName, defineValue in pairs(self.defines) do
		buffer:insert('#define ' .. defineName .. ' ' .. defineValue)
	end
	for defineName, defineValue in pairs(self.ensureDefinitions) do
		buffer:insert('#ifndef ' .. defineName)
		buffer:insert('# define ' .. defineName .. ' ' .. defineValue)
		buffer:insert('#endif')
	end
	return buffer
end

function module:toCPreprocessorText(newline)
	return self:toCPreprocessorTextLines():concat(newline)
end

function module:_ensureDefinition(defineName, enable, defineValue)
	if defineValue ~= nil then
		assert.parameterTypeIsString('defineValue', defineValue)
	end
	self.ensureDefinitions[defineName] = defineValue
end

-- TODO: Build Variant
-- Define to 1 if translation of program messages to the user's native language is requested.
function module:ENABLE_NLS(enable)
	self:_boolean('ENABLE_NLS', enable)
end







-- Name of package
function module:PACKAGE(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the address where bug reports for this package should be sent.
function module:PACKAGE_BUGREPORT(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the full name of this package.
function module:PACKAGE_NAME(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the full name and version of this package.
function module:PACKAGE_STRING(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the one symbol short name of this package.
function module:PACKAGE_TARNAME(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the home page for this package.
function module:PACKAGE_URL(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Define to the version of this package.
function module:PACKAGE_VERSION(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end

-- Version number of package
function module:VERSION(stringToQuote)
	self:_quotedNotEmptyString(stringToQuote)
end




-- Define to 1 if the `closedir' function returns void instead of `int'.
function module:CLOSEDIR_VOID(enable)
	self:_boolean('CLOSEDIR_VOID', enable)
end

-- Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP systems. This function is required for `alloca.c' support on those systems.
function module:CRAY_STACKSEG_END(constant)
	self:_enumeration('CRAY_STACKSEG_END', constant)
end

-- Define to 1 if using `alloca.c'.
function module:C_ALLOCA(enable)
	self:_boolean('C_ALLOCA', enable)
end

-- Define to 1 if using `getloadavg.c'.
function module:C_GETLOADAVG(enable)
	self:_boolean('C_GETLOADAVG', enable)
end

-- Define to 1 for DGUX with <sys/dg_sys_info.h>.
function module:DGUX(enable)
	self:_boolean('DGUX', enable)
end

-- Define to 1 if the `getloadavg' function needs to be run setuid or setgid..
function module:GETLOADAVG_PRIVILEGED(enable)
	self:_boolean('GETLOADAVG_PRIVILEGED', enable)
end

-- Define to 1 if you have `alloca', as a function or macro.
function module:HAVE_ALLOCA(enable)
	self:_boolean('HAVE_ALLOCA', enable)
end

-- Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
function module:HAVE_ALLOCA_H(enable)
	self:_boolean('HAVE_ALLOCA_H', enable)
end

-- Define to 1 if you have the `atexit' function.
function module:HAVE_ATEXIT(enable)
	self:_boolean('HAVE_ATEXIT', enable)
end

-- Define to 1 if you have the MacOS X function CFLocaleCopyCurrent in the CoreFoundation framework.
function module:HAVE_CFLOCALECOPYCURRENT(enable)
	self:_boolean('HAVE_CFLOCALECOPYCURRENT', enable)
end

-- Define to 1 if you have the MacOS X function CFPreferencesCopyAppValue in the CoreFoundation framework.
function module:HAVE_CFPREFERENCESCOPYAPPVALUE(enable)
	self:_boolean('HAVE_CFPREFERENCESCOPYAPPVALUE', enable)
end

-- Define to 1 if you have the clock_gettime function.
function module:HAVE_CLOCK_GETTIME(enable)
	self:_boolean('HAVE_CLOCK_GETTIME', enable)
end

-- Define if the GNU dcgettext() function is already present or preinstalled.
function module:HAVE_DCGETTEXT(enable)
	self:_boolean('HAVE_DCGETTEXT', enable)
end

-- Mandatory
-- Define to 1 if you have the declaration of `bsd_signal', and to 0 if you don't.
function module:HAVE_DECL_BSD_SIGNAL(enable)
	self:_oneOrZero('HAVE_DECL_BSD_SIGNAL', enable)
end

-- Define to 1 if you have the <dirent.h> header file, and it defines `DIR'.
function module:HAVE_DIRENT_H(enable)
	self:_oneOrZero('HAVE_DIRENT_H', enable)
end

-- Define to 1 if you have the `dup' function.
function module:HAVE_DUP(enable)
	self:_boolean('HAVE_DUP', enable)
end

-- Define to 1 if you have the `dup2' function.
function module:HAVE_DUP2(enable)
	self:_boolean('HAVE_DUP2', enable)
end

-- Define to 1 if you have the <fcntl.h> header file.
function module:HAVE_FCNTL_H(enable)
	self:_boolean('HAVE_FCNTL_H', enable)
end

-- Define to 1 if you have the `fdopen' function.
function module:HAVE_FDOPEN(enable)
	self:_boolean('HAVE_FDOPEN', enable)
end

-- Define to 1 if you have the `fileno' function.
function module:HAVE_FILENO(enable)
	self:_boolean('HAVE_FILENO', enable)
end

-- Define to 1 if you have the `getcwd' function.
function module:HAVE_GETCWD(enable)
	self:_boolean('HAVE_GETCWD', enable)
end

-- Define to 1 if you have the `getgroups' function.
function module:HAVE_GETGROUPS(enable)
	self:_boolean('HAVE_GETGROUPS', enable)
end

-- Define to 1 if you have the `gethostbyname' function.
function module:HAVE_GETHOSTBYNAME(enable)
	self:_boolean('HAVE_GETHOSTBYNAME', enable)
end

-- Define to 1 if you have the `gethostname' function.
function module:HAVE_GETHOSTNAME(enable)
	self:_boolean('HAVE_GETHOSTNAME', enable)
end

-- Define to 1 if you have the `getloadavg' function.
function module:HAVE_GETLOADAVG(enable)
	self:_boolean('HAVE_GETLOADAVG', enable)
end

-- Define to 1 if you have the `getrlimit' function.
function module:HAVE_GETRLIMIT(enable)
	self:_boolean('HAVE_GETRLIMIT', enable)
end

-- Define if the GNU gettext() function is already present or preinstalled.
function module:HAVE_GETTEXT(enable)
	self:_boolean('HAVE_GETTEXT', enable)
end

-- Define if you have the iconv() function and it works.
function module:HAVE_ICONV(enable)
	self:_boolean('HAVE_ICONV', enable)
end

-- Define to 1 if you have the <inttypes.h> header file.
function module:HAVE_INTTYPES_H(enable)
	self:_boolean('HAVE_INTTYPES_H', enable)
end

-- Define to 1 if you have the `isatty' function.
function module:HAVE_ISATTY(enable)
	self:_boolean('HAVE_ISATTY', enable)
end

-- Define to 1 if you have the `dgc' library (-ldgc).
function module:HAVE_LIBDGC(enable)
	self:_boolean('HAVE_LIBDGC', enable)
end

-- Define to 1 if you have the `kstat' library (-lkstat).
function module:HAVE_LIBKSTAT(enable)
	self:_boolean('HAVE_LIBKSTAT', enable)
end

-- Define to 1 if you have the <limits.h> header file.
function module:HAVE_LIMITS_H(enable)
	self:_boolean('HAVE_LIMITS_H', enable)
end

-- Define to 1 if you have the <locale.h> header file.
function module:HAVE_LOCALE_H(enable)
	self:_boolean('HAVE_LOCALE_H', enable)
end

-- Define to 1 if you have the `lstat' function.
function module:HAVE_LSTAT(enable)
	self:_boolean('HAVE_LSTAT', enable)
end

-- Define to 1 if you have the <mach/mach.h> header file.
function module:HAVE_MACH_MACH_H(enable)
	self:_boolean('HAVE_MACH_MACH_H', enable)
end

-- Define to 1 if you have the <memory.h> header file.
function module:HAVE_MEMORY_H(enable)
	self:_boolean('HAVE_MEMORY_H', enable)
end

-- Define to 1 if you have the `mkstemp' function.
function module:HAVE_MKSTEMP(enable)
	self:_boolean('HAVE_MKSTEMP', enable)
end

-- Define to 1 if you have the `mktemp' function.
function module:HAVE_MKTEMP(enable)
	self:_boolean('HAVE_MKTEMP', enable)
end

-- Define to 1 if you have the <ndir.h> header file, and it defines `DIR'.
function module:HAVE_NDIR_H(enable)
	self:_boolean('HAVE_NDIR_H', enable)
end

-- Define to 1 if you have the <nlist.h> header file.
function module:HAVE_NLIST_H(enable)
	self:_boolean('HAVE_NLIST_H', enable)
end

-- Define to 1 if you have the `pipe' function.
function module:HAVE_PIPE(enable)
	self:_boolean('HAVE_PIPE', enable)
end

-- Define to 1 if you have the `pstat_getdynamic' function.
function module:HAVE_PSTAT_GETDYNAMIC(enable)
	self:_boolean('HAVE_PSTAT_GETDYNAMIC', enable)
end

-- Define to 1 if you have the `readlink' function.
function module:HAVE_READLINK(enable)
	self:_boolean('HAVE_READLINK', enable)
end

-- Define to 1 if you have the `realpath' function.
function module:HAVE_REALPATH(enable)
	self:_boolean('HAVE_REALPATH', enable)
end

-- Define to 1 if you have the `setegid' function.
function module:HAVE_SETEGID(enable)
	self:_boolean('HAVE_SETEGID', enable)
end

-- Define to 1 if you have the `seteuid' function.
function module:HAVE_SETEUID(enable)
	self:_boolean('HAVE_SETEUID', enable)
end

-- Define to 1 if you have the `setlinebuf' function.
function module:HAVE_SETLINEBUF(enable)
	self:_boolean('HAVE_SETLINEBUF', enable)
end

-- Define to 1 if you have the `setlocale' function.
function module:HAVE_SETLOCALE(enable)
	self:_boolean('HAVE_SETLOCALE', enable)
end

-- Define to 1 if you have the `setregid' function.
function module:HAVE_SETREGID(enable)
	self:_boolean('HAVE_SETREGID', enable)
end

-- Define to 1 if you have the `setreuid' function.
function module:HAVE_SETREUID(enable)
	self:_boolean('HAVE_SETREUID', enable)
end

-- Define to 1 if you have the `setrlimit' function.
function module:HAVE_SETRLIMIT(enable)
	self:_boolean('HAVE_SETRLIMIT', enable)
end

-- Define to 1 if you have the `setvbuf' function.
function module:HAVE_SETVBUF(enable)
	self:_boolean('HAVE_SETVBUF', enable)
end

-- Define to 1 if you have the `sigaction' function.
function module:HAVE_SIGACTION(enable)
	self:_boolean('HAVE_SIGACTION', enable)
end

-- Define to 1 if you have the `sigsetmask' function.
function module:HAVE_SIGSETMASK(enable)
	self:_boolean('HAVE_SIGSETMASK', enable)
end

-- Define to 1 if you have the `socket' function.
function module:HAVE_SOCKET(enable)
	self:_boolean('HAVE_SOCKET', enable)
end

-- Define to 1 if you have the <stdint.h> header file.
function module:HAVE_STDINT_H(enable)
	self:_boolean('HAVE_STDINT_H', enable)
end

-- Define to 1 if you have the <stdlib.h> header file.
function module:HAVE_STDLIB_H(enable)
	self:_boolean('HAVE_STDLIB_H', enable)
end

-- Define to 1 if you have the `strcasecmp' function.
function module:HAVE_STRCASECMP(enable)
	self:_boolean('HAVE_STRCASECMP', enable)
end

-- Define to 1 if you have the `strcmpi' function.
function module:HAVE_STRCMPI(enable)
	self:_boolean('HAVE_STRCMPI', enable)
end

-- Define to 1 if you have the `strcoll' function and it is properly defined.
function module:HAVE_STRCOLL(enable)
	self:_boolean('HAVE_STRCOLL', enable)
end

-- Define to 1 if you have the `strdup' function.
function module:HAVE_STRDUP(enable)
	self:_boolean('HAVE_STRDUP', enable)
end

-- Define to 1 if you have the `strerror' function.
function module:HAVE_STRERROR(enable)
	self:_boolean('HAVE_STRERROR', enable)
end

-- Define to 1 if you have the `stricmp' function.
function module:HAVE_STRICMP(enable)
	self:_boolean('HAVE_STRICMP', enable)
end

-- Define to 1 if you have the <strings.h> header file.
function module:HAVE_STRINGS_H(enable)
	self:_boolean('HAVE_STRINGS_H', enable)
end

-- Define to 1 if you have the <string.h> header file.
function module:HAVE_STRING_H(enable)
	self:_boolean('HAVE_STRING_H', enable)
end

-- Define to 1 if you have the `strncasecmp' function.
function module:HAVE_STRNCASECMP(enable)
	self:_boolean('HAVE_STRNCASECMP', enable)
end

-- Define to 1 if you have the `strncmpi' function.
function module:HAVE_STRNCMPI(enable)
	self:_boolean('HAVE_STRNCMPI', enable)
end

-- Define to 1 if you have the `strndup' function.
function module:HAVE_STRNDUP(enable)
	self:_boolean('HAVE_STRNDUP', enable)
end

-- Define to 1 if you have the `strnicmp' function.
function module:HAVE_STRNICMP(enable)
	self:_boolean('HAVE_STRNICMP', enable)
end

-- Define to 1 if you have the `strsignal' function.
function module:HAVE_STRSIGNAL(enable)
	self:_boolean('HAVE_STRSIGNAL', enable)
end

-- Define to 1 if `n_un.n_name' is a member of `struct nlist'.
function module:HAVE_STRUCT_NLIST_N_UN_N_NAME(enable)
	self:_boolean('HAVE_STRUCT_NLIST_N_UN_N_NAME', enable)
end

-- Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
function module:HAVE_SYS_DIR_H(enable)
	self:_boolean('HAVE_SYS_DIR_H', enable)
end

-- Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
function module:HAVE_SYS_NDIR_H(enable)
	self:_boolean('HAVE_SYS_NDIR_H', enable)
end

-- Define to 1 if you have the <sys/param.h> header file.
function module:HAVE_SYS_PARAM_H(enable)
	self:_boolean('HAVE_SYS_PARAM_H', enable)
end

-- Define to 1 if you have the <sys/resource.h> header file.
function module:HAVE_SYS_RESOURCE_H(enable)
	self:_boolean('HAVE_SYS_RESOURCE_H', enable)
end

-- Define to 1 if you have the <sys/stat.h> header file.
function module:HAVE_SYS_STAT_H(enable)
	self:_boolean('HAVE_SYS_STAT_H', enable)
end

-- Define to 1 if you have the <sys/timeb.h> header file.
function module:HAVE_SYS_TIMEB_H(enable)
	self:_boolean('HAVE_SYS_TIMEB_H', enable)
end

-- Define to 1 if you have the <sys/time.h> header file.
function module:HAVE_SYS_TIME_H(enable)
	self:_boolean('HAVE_SYS_TIME_H', enable)
end

-- Define to 1 if you have the <sys/types.h> header file.
function module:HAVE_SYS_TYPES_H(enable)
	self:_boolean('HAVE_SYS_TYPES_H', enable)
end

-- Define to 1 if you have the <sys/wait.h> header file.
function module:HAVE_SYS_WAIT_H(enable)
	self:_boolean('HAVE_SYS_WAIT_H', enable)
end

-- Define to 1 if you have the `ttyname' function.
function module:HAVE_TTYNAME(enable)
	self:_boolean('HAVE_TTYNAME', enable)
end

-- Define to 1 if you have the <unistd.h> header file.
function module:HAVE_UNISTD_H(enable)
	self:_boolean('HAVE_UNISTD_H', enable)
end

-- Define to 1 if you have the `wait3' function.
function module:HAVE_WAIT3(enable)
	self:_boolean('HAVE_WAIT3', enable)
end

-- Define to 1 if you have the `waitpid' function.
function module:HAVE_WAITPID(enable)
	self:_boolean('HAVE_WAITPID', enable)
end

-- Define to 1 if your `struct nlist' has an `n_un' member. Obsolete, depend on `HAVE_STRUCT_NLIST_N_UN_N_NAME
function module:NLIST_NAME_UNION(enable)
	self:_boolean('NLIST_NAME_UNION', enable)
end

-- Mandatory
-- Define to the character that separates directories in PATH.
assert.globalTableHasChieldFieldOfTypeFunction('string', 'len')
function module:PATH_SEPARATOR_CHAR(character)
	assert.parameterTypeIsString('character', character)
	if character:len() ~= 1 then
		exception.throw("The path separator character must be exactly one character, it can not be '%s'", character)
	end
	
	self.defines.PATH_SEPARATOR_CHAR = character
end

-- Mandatory
-- Define as the return type of signal handlers (`int' or `void').
function module:RETSIGTYPE(constant)
	self:_enumeration('RETSIGTYPE', constant)
end

-- If using the C implementation of alloca, define if you know the direction of stack growth for your system; otherwise it will be automatically deduced at runtime.
function module:STACK_DIRECTION(constant)
	self:_enumeration('STACK_DIRECTION', constant)
end

-- Define to 1 if the `S_IS*' macros in <sys/stat.h> do not work properly.
function module:STAT_MACROS_BROKEN(enable)
	self:_boolean('STAT_MACROS_BROKEN', enable)
end

-- Define to 1 if you have the ANSI C header files.
function module:STDC_HEADERS(enable)
	self:_boolean('STDC_HEADERS', enable)
end

-- Define if struct stat contains a nanoseconds field
function module:ST_MTIM_NSEC(constant)
	self:_enumeration('ST_MTIM_NSEC', constant)
end

-- Define to 1 on System V Release 4.
function module:SVR4(enable)
	self:_boolean('SVR4', enable)
end

-- Define to 1 if you can safely include both <sys/time.h> and <time.h>.
function module:TIME_WITH_SYS_TIME(enable)
	self:_boolean('TIME_WITH_SYS_TIME', enable)
end

-- Define to 1 for Encore UMAX.
function module:UMAX(enable)
	self:_boolean('UMAX', enable)
end

-- Define to 1 for Encore UMAX 4.3 that has <inq_status/cpustats.h> instead of <sys/cpustats.h>.
function module:UMAX4_3(enable)
	self:_boolean('UMAX4_3', enable)
end



-- AC_SYS_LARGEFILE  (Large file support; Irix 6.2+ CC needs '-n32')
-- Enable large inode numbers on Mac OS X 10.5.
function module:_DARWIN_USE_64_BIT_INODE(enable)
	self:_ensureDefinition('_DARWIN_USE_64_BIT_INODE', enable, '1')
end

-- AC_SYS_LARGEFILE
-- Number of bits in a file offset, on hosts where this is settable.
function module:_FILE_OFFSET_BITS(enable)
	self:_boolean('_FILE_OFFSET_BITS', enable)
end

-- AC_SYS_LARGEFILE
-- Define for large files, on AIX-style hosts.
function module:_LARGE_FILES(enable)
	self:_boolean('_LARGE_FILES', enable)
end



-- AC_USE_SYSTEM_EXTENSIONS
-- Define to 2 if the system does not provide POSIX.1 features except with this defined.
-- MINIX only
function module:_POSIX_1_SOURCE(enable)
	if enable then
		self.definitions['_POSIX_1_SOURCE'] = '2'
	else
		self:_undefine('_POSIX_1_SOURCE')
	end
end

-- AC_USE_SYSTEM_EXTENSIONS
-- Define to 1 if you need to in order for `stat' and other things to work.
-- MINIX only
function module:_POSIX_SOURCE(enable)
	self:_boolean('_POSIX_SOURCE', enable)
end

-- Define to 1 if on MINIX.
-- MINIX only
function module:_MINIX(enable)
	self:_boolean('_MINIX', enable)
end

-- Enable extensions on AIX 3, Interix.
function module:_ALL_SOURCE(enable)
	self:_ensureDefinition('_ALL_SOURCE', enable, '1')
end

-- Enable GNU extensions on systems that have them. 
function module:_GNU_SOURCE(enable)
	self:_ensureDefinition('_GNU_SOURCE', enable, '1')
end

-- Enable threading extensions on Solaris.
function module:_POSIX_PTHREAD_SEMANTICS(enable)
	self:_ensureDefinition('_POSIX_PTHREAD_SEMANTICS', enable, '1')
end

-- Enable extensions on HP NonStop.
function module:_TANDEM_SOURCE(enable)
	self:_ensureDefinition('_TANDEM_SOURCE', enable, '1')
end

-- Enable general extensions on Solaris.
function module:_TANDEM_SOURCE(enable)
	self:_ensureDefinition('__EXTENSIONS__', enable, '1')
end

-- Define to empty if `const' does not conform to ANSI C.
function module:const(enable)
	self:_defineIfMissing('const', enable, '')
end

-- Define to `int' if <sys/types.h> doesn't define.
function module:uid_t(enable)
	self:_defineIfMissing('uid_t', enable, 'int')
end

-- Define to `int' if <sys/types.h> doesn't define.
function module:gid_t(enable)
	self:_defineIfMissing('gid_t', enable, 'int')
end

function module:WITH_DMALLOC(enable)
	self:_boolean('WITH_DMALLOC', enable)
end
