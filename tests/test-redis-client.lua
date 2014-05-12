local redis = require '../redis_conn'
local async = require 'async'

redis.connect({host='localhost', port=6379}, function(client)
   local list = List.new()

   local int = async.setInterval(1000,function()
      client.get("123456543", function(res) 
         list:append(res)
      end)
   end)
   async.setTimeout(2100000, function()
      client.close()
      int.clear()
      for _,res in ipairs(list) do 
         print(pretty.write(res))
      end
   end)
end)

async.go()
