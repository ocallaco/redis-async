codec = require '../codec'

-- tests
-- status
print('\n\ntesting status')
status_buff = "+OK\r\n"
print(pretty.write(codec.decode(status_buff)))

-- error
print('\n\ntesting error')
err_buff = "-SHIT hole is full of crap\r\n"
print(codec.decode(err_buff))

-- number 
print('\n\ntesting number')
err_buff = ":12345\r\n"
print(codec.decode(err_buff))

-- bulk
print('\n\ntesting bulk')
err_buff = "$4\r\nabcd\r\n"
print(codec.decode(err_buff))

-- bulk
print('\n\ntesting multibulk')
err_buff = "*4\r\n$4\r\nabcd\r\n$5\r\ndefgh\r\n$3\r\nyui\r\n"
print(codec.decode(err_buff))
