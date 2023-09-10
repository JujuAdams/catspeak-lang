var _string = @'
Log(self)
global.q = "meow"
Log(self)

Log("outside")
let thing = use Builder {
    x = 42
    Log(self)
    MethodTest("wow")
    Log("inside A")
    
    use Builder {
        y = 3.1412
        MethodTest("b")
        Log("inside B")
    }
}

use Builder {
    y = 3.1412
    MethodTest("c")
    Log("inside C")
}

Log("end")

Log(global)

return thing
';

Pugspeak.interface.exposeFunction("Log", function(_value)
{
    //show_debug_message(debug_get_callstack());
    show_debug_message(_value);
});

Pugspeak.interface.exposeFunction("Builder", function()
{
    PugspeakScopePush(new ClassTest());
    
    return function()
    {
        var _scope = PugspeakScope();
        PugspeakScopePop();
        return _scope;
    }
});

show_debug_message(PugspeakExecute(_string));
show_debug_message("globalVars = " + string(Pugspeak.globalVars));