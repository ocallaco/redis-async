local redis = require '../redis_conn'
--local redis = require 'redis-async'

local async = require 'async'
local fiber = require 'async.fiber'

fiber(function()
redis.connect({host='localhost', port=6379}, function(client)
   local counter = 0

   local f1 = function(client)
      counter = counter + 1
      client.set("TEST", counter, function(res) end)
   end

   local f2 = function()
      local my_count = counter
      client.get("TEST", function(res)
         if tonumber(res) ~= my_count then
            print("FAILURE!!!!!!")
         else
            print("Received response '" .. res .. "' on attempt " .. my_count)
         end
      end)
   end

   for i = 1,2000 do
      f1(client)
      f2(client)
   end

end)
end)


async.go()

