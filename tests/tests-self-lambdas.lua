local o = {}

function o:f()
    return function()
        return self
    end
end

print(o, o:f()())