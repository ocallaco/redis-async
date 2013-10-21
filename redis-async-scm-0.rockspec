package = "redis-async"
version = "scm-0"

source = {
   url = "git://github.com/ocallaco/redis-async",
   branch = "master"
}

description = {
   summary = "A redis client built off the torch/lua async framework",
   detailed = [[
A redis client built off the torch/lua async framework
   ]],
   homepage = "https://github.com/ocallaco/redis-async",
   license = "BSD"
}

dependencies = {
   "async",
   "sys >= 1.0"
}

build = {
   type = "builtin",
   modules = {
      ['redis-async.init'] = 'init.lua',
   }
}
