-- tcp
local tcp = require 'async.tcp'

-- redis commands

local GET = "GET"
local SET = "SET"

RedisClient = {}
local codec = require 'redis-async.codec'
local commands = require 'redis-async.commands'


function RedisClient.connect(domain, cb)
   tcp.connect(domain, function(client)
     
      client.send = function(tbl)
         local req = codec.encode(tbl)
         client.write(req)
      end

      for _,command in ipairs(commands) do 
         client[command:lower()] = function(...)
            local com_args = List.new({command, ...})
            local last_arg = com_args[#com_args]

            local callback = function(res) return res end

            if type(last_arg) == 'function' then
               callback = com_args:pop()
            end

            client.send(com_args)

            client.callback_queue:append(callback)

         end
      end

      client.ondata(function(data)
         local res = codec.decode(data)

         local callback = client.callback_queue:pop(1)

         if callback then
            callback(res)
         end
      end)

      client.callback_queue = List.new()

      cb(client)
   end)
end

-- return
return RedisClient
