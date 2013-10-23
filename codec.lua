local codec = {}

local delim = "\r\n"

local function decodeStatus(buffer)
   return {status = buffer:find("(.+)" .. delim)}
end

local function decodeError(buffer)
   local _,_,err_type,msg = buffer:find("(%a+) (.+)" .. delim)
   return {error = {
      type = err_type,
      message = msg
   }}
end

local function decodeNumber(buffer)
   local _,_,num = buffer:find("(%d+)"..delim)
   return tonumber(num)
end

local function decodeBulk(buffer)
   local entries = stringx.split(buffer, delim)
   return entries[2]
end

local function decodeMultibulk(buffer)
   local entries = List.new(stringx.split(buffer, delim))
   local response = {}
   for i = 3,#entries,2 do
      table.insert(response, entries[i])
   end

   return response
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

codec.decode = function(buffer)
   local buffer_list = List.new(buffer)

   local res_type = buffer_list[1]
   local remainder = table.concat(buffer_list:slice(2,#buffer_list))

   if res_type == "+" then
      return decodeStatus(remainder)
   elseif res_type == "-" then
      return decodeError(remainder)
   elseif res_type == ":" then
      return decodeNumber(remainder)
   elseif res_type == "$" then
      return decodeBulk(remainder)
   elseif res_type == "*" then
      return decodeMultibulk(remainder)
   end
end

return codec
