var _string = @'
Log("outside")
var thing = use Builder {
    x = 42
    MethodTest("wow")
    Log("inside")
}
Log("end")

return thing
';

Catspeak.getInterface();
Catspeak.interface.exposeFunction("Log", function(_value)
{
    //show_debug_message(debug_get_callstack());
    show_debug_message(_value);
});

Catspeak.interface.exposeFunction("Builder", function()
{
    var _struct = new ClassTest();
    contextPush(_struct);
    catspeakPushGlobals(_struct);
    
    return function()
    {
        catspeakPopGlobals();
        return contextPop();
    }
});

var _asg = Catspeak.parseString(_string);
func = Catspeak.compileGML(_asg);

show_debug_message(func());