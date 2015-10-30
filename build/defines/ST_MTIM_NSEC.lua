--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local stringEnumerationClass = require('halimede.enumeration').stringEnumerationClass


-- Derived from acinclude.m4 in GNU make 4.1
return stringEnumerationClass('ST_MTIM_NSEC',
	'tv_nsec',                   -- The usual case
	'_tv_nsec',                  -- Solaris 2.6, if (defined _XOPEN_SOURCE && _XOPEN_SOURCE_EXTENDED == 1 && !defined __EXTENSIONS__)
	'st_mtim.st__tim.tv_nsec',   -- UnixWare 2.1.2
	'st_mtime_n',                -- AIX 5.2 and above
	'st_mtimespec.tv_nsec'       -- Darwin / MacOSX
)
