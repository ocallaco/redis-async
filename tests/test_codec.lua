codec = require '../codec'
b = require 'buffer'

-- tests
-- status
print('\n\ntesting status')
status_buff = "+OK\r\n"
--limit = codec.findMessageLimit(status_buff)
--print('limit test: ' .. limit .. ' should be ' .. #status_buff)
print(pretty.write(codec.decode(status_buff)))

-- error
print('\n\ntesting error')
err_buff = "-ERR1 some error message! please fix\r\n"
--limit = codec.findMessageLimit(err_buff)
--print('limit test: ' .. limit .. ' should be ' .. #err_buff)
print(codec.decode(err_buff))

-- number 
print('\n\ntesting number')
err_buff = ":12345\r\n"
--limit = codec.findMessageLimit(err_buff)
--print('limit test: ' .. limit .. ' should be ' .. #err_buff)
print(codec.decode(err_buff))

-- bulk
print('\n\ntesting bulk')
err_buff = "$4\r\nabcd\r\n"
--limit = codec.findMessageLimit(err_buff)
--print('limit test: ' .. limit .. ' should be ' .. #err_buff)
print(codec.decode(err_buff))

-- bulk nil
print('\n\ntesting bulk nil')
err_buff = "$-1\r\n"
--limit = codec.findMessageLimit(b(err_buff))
--print('limit test: ' .. limit .. ' should be ' .. #err_buff)
print(codec.decode(err_buff))

-- bulk
print('\n\ntesting multibulk')
err_buff = "*3\r\n$4\r\nabcd\r\n$5\r\ndefgh\r\n$3\r\nyui\r\n"
--limit = codec.findMessageLimit(err_buff)
--print('limit test: ' .. limit .. ' should be ' .. #err_buff)
print(codec.decode(err_buff))


print('\n\ntesting multibulk 2')
err_buff = "*3\r\n$9\r\nsubscribe\r\n$13\r\nconallchannel\r\n:1\r\n"
--limit = codec.findMessageLimit(err_buff)
--print('limit test: ' .. limit .. ' should be ' .. #err_buff)
print(codec.decode(err_buff))

print('\n\n testing grouped messages')
err_buff = "*3\r\n$4\r\nabcd\r\n$5\r\ndefgh\r\n$3\r\nyui\r\n-ERR1 some error message! please fix\r\n$4\r\nabc\r\n"
messages, incomplete = codec.splitMessages(err_buff)

table.insert(messages, incomplete)
for i,message in ipairs(messages) do print(pretty.write(message)) end
