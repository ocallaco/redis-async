local redis = require 'redis-async'
local async = require 'async'

redis.connect({host='localhost', port=6379}, function(client)
   local list = List.new()

   local int = async.setInterval(1000,function()
      client.get("TEST", function(res) 
         list:append(res)
      end)
   end)
   async.setTimeout(2100, function()
      client.close()
      int.clear()
      for _,res in ipairs(list) do 
         print(pretty.write(res))
      end
   end)
end)

async.go()
