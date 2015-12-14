TODO:-

- compile bitop standalone (for older Lua)
- compile luacompat_5.2
- compile luacompat_5.3
- compile luaffib
- compile / use ljsyscall

- implement a move script action
	- for make recipe
	- longterm evolution into an 'install' function

- have a '.build' folder for out-of-tree builds
	- config.h needs to go into here
	- *.o files in here

- experiment with -combine for faster (and more optimised) C builds

- experiment with -flto / -fwhopr

Toolchains
	- MinGW64 on
		- Linux
		- Mac OS X
	- Mac OS X
		- Mavericks
		- Yosemite
		- El Capitan
		- AVR / ARM instructions: http://www.ethernut.de/en/documents/cross-toolchain-osx.html
	- A toolchain option to 'try latest' (eg so one can try the next Mac OS X release even if no toolchain defined)
	- Rump Kernel
	- OSv
	- Custom Linux
		- Ubuntu 12.04 / 14.04
		- Mac OS X (all versions)

- bootstrap

- hashing using SHA256 (need some sort of Pure Lua solution in order to get started)

Short Term Goals
	- Command line parsing
	- Build interceptor
		- each program executed is intercepted
		- we use a 'mkdir' to act as a lock
		- print command executed to screen
		- build interceptor script is generated at runtime
		- POSIX-only

Medium Term Goals
	- See if miniperl or microperl can be used to bootstrap auto* cruft

Long Term Goals
	- replacement of auto* cruft using Lua code
	- replacement of M4 using Lua code

Very Long Term Goals
	- replacement of shell, dash, with Lua-based code
	- replacement of enough of a C compiler and linker to compile make, lua, luajit, dash, etc using a Lua-based C compiler for Arm & X86 on Linux


Bootstrapping to a build system

* Varies by platform
	* Mac OS X:-
		* Has complete toolchains we're supposed to use
		* Lacks autotools cruft
		* Some GNU programs may be very dated, as Apple does not use anything licensed under GPL3
		* How do switch toolchains?
			* `xcrun`, `xcode-select`, `SDKROOT`, `DEVELOPER_DIR` and `xcodebuild -showsdks` and <https://github.com/phracker/MacOSX-SDKs>
		* The default toolchain root is `/Applications/Xcode.app/Contents/Developer/` but the SDK may be for a more recent Mac OS X
			* As of El Capitan, `gcc`, `g++`, `make` (and `gnumake`, currently the same as `make`), `ld`, `nasm`, `svn`, `git` and, interestingly, `pngcrush`
* build binutils
	* needs a lot of things in place already
	* not needed for Mac OS X
*