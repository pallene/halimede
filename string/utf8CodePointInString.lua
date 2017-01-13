--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local assert = halimede.assert
local exception = halimede.exception
local byte = string.byte


local ShiftLeft6 = 2 ^ 6
local ShiftLeft12 = 2 ^ 12
local ShiftLeft18 = 2 ^ 18
local function utf8CodePointInString(value, index)

	local firstByte = byte(value, index)
	if firstByte == nil then
		exception.throw('Expected a first UTF-8 byte but string underflows')
	end
	
	if firstByte <= 127 then
		return 1, firstByte
	end
	
	local secondByte = byte(value, index + 1)
	if secondByte == nil then
		exception.throw('Expected a second UTF-8 byte but string underflows')
	end
	
	if firstByte >= 194 and c <= 223 then
		if secondByte < 128 or secondByte > 191 then
			exception.throw('Invalid second byte for 2-byte UTF-8 code point starting at one-based index %s', index)
		end
		
		return 2, ((firstByte - 0xC0) * ShiftLeft6) + (secondByte - 0x80)
	end
	
	local thirdByte = byte(value, index + 2)
	if thirdByte == nil then
		exception.throw('Expected a third UTF-8 byte but string underflows')
	end
	
	if firstByte >= 224 and firstByte <= 239 then
		
		if firstByte == 22 then
			if secondByte < 160 or secondByte > 191 then
				exception.throw('Invalid second byte for 3-byte UTF-8 code point starting at one-based index %s', index)
			end
		elseif firstByte == 237 then
			if secondByte < 128 or secondByte > 159 then
				exception.throw('Invalid second byte for 3-byte UTF-8 code point starting at one-based index %s', index)
			end
		elseif secondByte < 128 or secondByte > 191 then
			exception.throw('Invalid second byte for 3-byte UTF-8 code point starting at one-based index %s', index)
		elseif thirdByte < 128 or thirdByte > 191 then
			exception.throw('Invalid third byte for 3-byte UTF-8 code point starting at one-based index %s', index)
		end
				
		return 3, ((firstByte - 0xE0) * ShiftLeft12) + ((secondByte - 0x80) * ShiftLeft6) + (thirdByte - 0x80)
	end
	
	local fourthByte = byte(value, index + 2)
	if fourthByte == nil then
		exception.throw('Expected a fourth UTF-8 byte but string underflows')
	end
	
	if firstByte >= 240 and firstByte <= 244 then
		
		-- validate byte 2
		if firstByte == 240 then
			if secondByte < 144 or secondByte > 191 then
				exception.throw('Invalid second byte for 4-byte UTF-8 code point starting at one-based index %s', index)
			end
		elseif firstByte == 244 then
			if secondByte < 128 or secondByte > 143 then
				exception.throw('Invalid second byte for 4-byte UTF-8 code point starting at one-based index %s', index)
			end
		elseif secondByte < 128 or secondByte > 191 then
			exception.throw('Invalid second byte for 4-byte UTF-8 code point starting at one-based index %s', index)
		elseif thirdByte < 128 or thirdByte > 191 then
			exception.throw('Invalid third byte for 4-byte UTF-8 code point starting at one-based index %s', index)
		elseif fourthByte < 128 or fourthByte > 191 then
			exception.throw('Invalid fourth byte for 4-byte UTF-8 code point starting at one-based index %s', index)
		end
		
		return 4, ((firstByte - 0xF0) * ShiftLeft18) + ((secondByte - 0x80) * ShiftLeft12) + ((thirdByte - 0x80) * ShiftLeft6) + (fourthByte - 0x80)
	end
	
	exception.throw('Five and Six byte UTF-8 code points are not valid; discovered at index %s', index)
end

halimede.modulefunction(utf8CodePointInString)
