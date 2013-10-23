-- tcp
local tcp = require 'async.tcp'

-- redis commands

local GET = "GET"
local SET = "SET"

RedisClient = {}
local codec = require './codec'
local commands = require './commands'


function RedisClient.connect(domain, cb)
   tcp.connect(domain, function(client)
     
      client.send = function(tbl)
         local req = codec.encode(tbl)
         client.write(req)
      end

      for _,command in ipairs(commands) do 
         client[command:lower()] = function(...)
            local args = List.new({command, ...})
            local last_arg = args[#args]

            local cb = function(res) return res end

            if type(last_arg == 'function') then
               cb = args:pop()
            end

            client.send(args)

            client.callback_queue:append(cb)
         end
      end

      client.ondata(function(data)
         res = codec.decode(data)
         local callback = client.callback_queue:pop(1)
         callback(res)
      end)

      client.callback_queue = List.new()

      cb(client)
   end)
end

-- return
return RedisClient
