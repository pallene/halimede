--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local Path = halimede.io.paths.Path
local openBinaryFileForReading = halimede.io.FileHandleStream.openBinaryFileForReading


-- builtin macros
moduleclass('Builtin')

function module:initialize(GNUext, macros, blind, function)
end

-- If --prefix-builtins or -P is used, then the names are renamed with a prefix of 'm4_'
-- GNUext refers to the fact that a builtin macro may be blind, ie  special handing of () (See manual 4.2)
local builtins = {
	__file__ = Builtin:new(true, false, false, m4___file__),
	__line__ = Builtin:new(true, false, false, m4___line__),
	__program__ = Builtin:new(true, false, false, m4___program__),
	builtin = Builtin:new(true, true, true, m4_builtin),
	changecom = Builtin:new(false, false, false, m4_changecom),
	changequote = Builtin:new(false, false, false, m4_changequote),
	changeword = Builtin:new(true, false, true, m4_changeword),
	debugmode = Builtin:new(true, false, false, m4_debugmode),
	debugfile = Builtin:new(true, false, false, m4_debugfile),
	decr = Builtin:new(false, false, true, m4_decr),
	define = Builtin:new(false, true, true, m4_define),
	defn = Builtin:new(false, false, true, m4_defn),
	divert = Builtin:new(false, false, false, m4_divert),
	divnum = Builtin:new(false, false, false, m4_divnum),
	dnl = Builtin:new(false, false, false, m4_dnl),
	dumpdef = Builtin:new(false, false, false, m4_dumpdef),
	errprint = Builtin:new(false, false, true, m4_errprint),
	esyscmd = Builtin:new(true, false, true, m4_esyscmd),
	eval = Builtin:new(false, false, true, m4_eval),
	format = Builtin:new(true, false, true, m4_format),
	ifdef = Builtin:new(false, false, true, m4_ifdef),
	ifelse = Builtin:new(false, false, true, m4_ifelse),
	include = Builtin:new(false, false, true, m4_include),
	incr = Builtin:new(false, false, true, m4_incr),
	index = Builtin:new(false, false, true, m4_index),
	indir = Builtin:new(true, true, true, m4_indir),
	len = Builtin:new(false, false, true, m4_len),
	m4exit = Builtin:new(false, false, false, m4_m4exit),
	m4wrap = Builtin:new(false, false, true, m4_m4wrap),
	maketemp = Builtin:new(false, false, true, m4_maketemp),
	mkstemp = Builtin:new(false, false, true, m4_mkstemp),
	patsubst = Builtin:new(true, false, true, m4_patsubst),
	popdef = Builtin:new(false, false, true, m4_popdef),
	pushdef = Builtin:new(false, true, true, m4_pushdef),
	regexp = Builtin:new(true, false, true, m4_regexp),
	shift = Builtin:new(false, false, true, m4_shift),
	sinclude = Builtin:new(false, false, true, m4_sinclude),
	substr = Builtin:new(false, false, true, m4_substr),
	syscmd = Builtin:new(false, false, true, m4_syscmd),
	sysval = Builtin:new(false, false, false, m4_sysval),
	traceoff = Builtin:new(false, false, false, m4_traceoff),
	traceon = Builtin:new(false, false, false, m4_traceon),
	translit = Builtin:new(false, false, true, m4_translit),
	undefine = Builtin:new(false, false, true, m4_undefine),
	undivert = Builtin:new(false, false, false, m4_undivert)
}

-- There are also predefined and user macros