var _string = @'
global.q = "meow"
Log("outside")
let thing = use Builder {
    x = 42
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
    PugspeakPushScope(new ClassTest());
    
    return function()
    {
        var _scope = PugspeakScope();
        PugspeakPopScope();
        return _scope;
    }
});

Pugspeak.interface.exposeConstant("global", PugspeakGetGlobal());

var _asg = Pugspeak.parseString(_string);
func = Pugspeak.compileGML(_asg);

show_debug_message(func());