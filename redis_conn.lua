-- tcp
local tcp = require 'async.tcp'
local Buffer = require 'buffer'

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

      for _,command in ipairs(commands.single) do 
         client[command:lower()] = function(...)
            local com_args = List.new({command, ...})
            local last_arg = com_args[#com_args]

            local callback = function(res) return res end

            if type(last_arg) == 'function' then
               callback = com_args:pop()
            end

            client.send(com_args)

            client.callbackQueue:append(callback)

         end
      end

      for _,command in ipairs(commands.subscription) do
         client[command:lower()] = function(...)
            local com_args = List.new({command, ...})
            local subname = com_args[2]
            local last_arg = com_args[#com_args]

            local callback = function(res) return res end

            if type(last_arg) == 'function' then
               callback = com_args:pop()
            end

            client.send(com_args)

            client.subscriptions[subname] = callback
         end

      end

      client.onsplitdata(codec.splitMessages, function(chunk)
         local res = codec.decode(chunk)

         local callback

         if type(res) == 'table' and res[1] == "message" then
            callback = client.subscriptions[res[2]] or function(x) return x end
         else
            callback = client.callbackQueue:pop(1)
         end
         

         if callback then
            callback(res)
         end
      end)

      client.callbackQueue = List.new()
      client.subscriptions = {}

      cb(client)
   end)
end

-- return
return RedisClient
