
require "tprint"
require "import"


-- local f, r = loadfile("t2.lua")
-- print(111, f, r)

-- local events = import('events')
-- local emitter3 = import('events')()
-- local emitter4 = import('events')()


local em = import('events')()
-- local emitter2 = events:new()
-- print(emitter == emitter2)
-- print(emitter2 == emitter3)
-- print(emitter4 == emitter3)

-- emitter:remove('test_on', test)
function test(...) 
    print('test_on 111 fires', ...)
end
function test2(...) 
    print('test_on 222 fires', ...)
end

em.on('test_on', test)
em.on('test_on', test2)

-- emitter:removeListener('test_on', test)
-- function test(...) 
--     print('test_on 111 fires', ...)
-- end
-- emitter:on('test_on', test)
em.emit('test_on', 1, 2, 3)



-- local ev = impoem



-- emitter:on('test_on', function () 
--     print('test_on 222 fires')
--     error(222)
-- end)
-- emitter:on('test_on', function () 
--     print('test_on 333 fires')
-- end)
-- emitter:on('test_on', function (...) 
--     print('test_on 444 fires', ...)
--     error(444)
-- end)

-- emitter:emit('test_on')

