local t= { 
            baseinfo = {}
         }

         for kk, vv in pairs(t) do

             setmetatable(vv,{
                 __newindex = function(g, k, v)
                     print("==k: " .. k)
                     rawset(g, k, v)
                 end
             })
         end



t.baseinfo.foo = "foo"
t.baseinfo.bar = 4

local baseinfo = t.baseinfo
baseinfo.gg = "gg"
