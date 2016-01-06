--[[
This file is part of halimede. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT. No part of halimede, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of halimede. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/halimede/master/COPYRIGHT.
]] --


local halimede = require('halimede')
local assert = halimede.assert
local type = halimede.type
local isFunction = type.isFunction
local isNotTable = type.isNotTable


assert.globalTypeIsFunctionOrCall('rawget', 'getmetatable')
local function getUnderlyingFunctionFromCallable(functionOrCall)
    if isFunction(functionOrCall) then
        return functionOrCall
    end

    if isNotTable(functionOrCall) then
        error('functionOrCall must be a function or table')
    end

    -- for halimede named functions
    local functor = rawget(functionOrCall, 'functor')
    if isFunction(functor) then
        return functor
    end

    local metatable = getmetatable(functionOrCall)
    if metatable == nil then
        error('functionOrCall must be a function or table with a metatable')
    end

    local wrapper = metatable.__call
    if wrapper == nil then
        error('functionOrCall must be a function or table with a metatable and __call')
    end

    return function(...)
        return wrapper(functionOrCall, ...)
    end
end
halimede.getUnderlyingFunctionFromCallable = getUnderlyingFunctionFromCallable
