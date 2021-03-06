// This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
// Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.


#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"


int main(const int argc, char **argv)
{
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	
	// Create _G.arg
	int argument;
	lua_createtable(L, argc, 1);
	for (argument = 0; argument < argc; argument++)
	{
		lua_pushstring(L, argv[argument]);
		lua_rawseti(L, -2, argument);
	}
	lua_setglobal(L, "arg");
	luaL_checkstack(L, argc - 1, "Stack can not grow");
	
	// Run
	lua_getglobal(L, "require");
	lua_pushliteral(L, "main");
	int status = lua_pcall(L, 1, 0, 0);
	if (status)
	{
		fprintf(stderr, "Error:%s\n", lua_tostring(L, -1));
		return 1;
	}
	return 0;
}
