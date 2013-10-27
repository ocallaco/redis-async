-- message types and ascii codes
-- *     42
-- +     43
-- -     45
-- :     58
-- $     36

local b = require 'buffer'

local MSGTYPES = {
   STATUS = 43,
   ERROR = 45,
   INTEGER = 58,
   BULK = 36,
   MULTIBULK = 42
}

local codec = {}

local delim = "\r\n"


local function decodeStatus(buffer)
   local limit = buffer:find(delim) 
   if limit then
      return {status = buffer:slice(1,limit - 1):toString()} 
   end
end

local function decodeError(buffer)
   local start = 1
   local limit = buffer:find(" ") - 1

   local errtype = buffer:slice(start, limit):toString()

   start = limit + 1
   limit = buffer:find(delim) - 1
   local msg = buffer:slice(start, limit):toString()

   return {error = {
      type = err_type,
      message = msg
   }}
end

local function decodeNumber(buffer)
   local limit = buffer:find(delim) - 1
   return tonumber(buffer:slice(1,limit):toString())
end

local function decodeBulk(buffer)
   local entries = buffer:split(delim)
   return entries[2]:toString()
end

local function decodeMultibulk(buffer)
   local entries = buffer:split(delim)
   local response = {}
   for i = 3,#entries,2 do
      table.insert(response, entries[i]:toString())
   end

   return response
end

local function findBulkLimit(buffer)
   local first_delim = buffer:find(delim)
   
   if first_delim then 
      local msgend =  buffer:find(delim, first_delim + #delim)
      if msgend then
         return msgend + #delim - 1
      end
   end
end

local function findMultiBulkLimit(buffer)
   local limit = buffer:find(delim)

   if limit == nil then return end

   local num = tonumber(buffer:slice(2,limit):toString())

   limit = limit + #delim

   for i = 1,num do
      limit = buffer:find(delim, limit)
      if limit then 
         limit = limit + #delim
      else
         return
      end

      limit = buffer:find(delim, limit)

      if limit then 
         limit = limit + #delim
      else
         return
      end

   end

   return limit - 1
end

--local function findMessageLimit(message)
local function findMessageLimit(message)
   local buffer = b(message)
   local msgtype = buffer[1]

   local limit 

   if (msgtype == MSGTYPES.STATUS) or (msgtype == MSGTYPES.ERROR) or (msgtype == MSGTYPES.INTEGER) then
      limit = buffer:find(delim)
      return limit and limit + #delim - 1
   elseif msgtype == MSGTYPES.BULK then
      return findBulkLimit(buffer)
   elseif msgtype == MSGTYPES.MULTIBULK then
      return findMultiBulkLimit(buffer)
   end
end

codec.encode = function(args)
   local buffer = {true,true}
   
   buffer[1] = '*' .. #args .. "\r\n"
   for i = 1,#args do
      local entry = tostring(args[i])
      buffer[i+1] = '$' .. #entry .. "\r\n" .. entry .. "\r\n"
   end

   return table.concat(buffer)
end

codec.decode = function(data)
   local buffer = b(data)

   local res_type = buffer[1]
   local remainder = buffer:slice(2,buffer.length)

   if res_type == MSGTYPES.STATUS then
      return decodeStatus(remainder)
   elseif res_type == MSGTYPES.ERROR then
      return decodeError(remainder)
   elseif res_type == MSGTYPES.INTEGER then
      return decodeNumber(remainder)
   elseif res_type == MSGTYPES.BULK then
      return decodeBulk(remainder)
   elseif res_type == MSGTYPES.MULTIBULK then
      return decodeMultibulk(remainder)
   end
end

-- returns a table of complete messages and an incomplete message if that's included
codec.splitMessages = function(chunk)

   local buffer = b(chunk)
    
   local messages = {}
   local index = 1

   while index < buffer.length do  
      local start = index
      local limit = findMessageLimit(buffer:slice(start, buffer.length)) 
  
      if limit ~= nil then
         limit = limit + start - 1
         local msg = buffer:slice(start, limit)
         table.insert(messages, msg:toString())
      else 
         break
      end

      index = limit + 1
   end

   local incomplete = ""
   if index < buffer.length then
      incomplete = buffer:slice(index, buffer.length):toString()
   end

   return messages, incomplete
end

return codec
