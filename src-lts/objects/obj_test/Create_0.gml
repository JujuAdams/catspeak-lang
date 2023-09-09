var _string = @'
use Builder {
    MethodTest("wow")
}
';

Catspeak.getInterface();
Catspeak.interface.exposeFunction("Log", function(_value)
{
    show_debug_message(debug_get_callstack());
    show_debug_message(_value);
});

Catspeak.interface.exposeFunction("Builder", function()
{
    var _struct = new ClassTest();
    contextPush(_struct);
    catspeakPushSelf(_struct);
    
    return function()
    {
        catspeakPopSelf();
        return contextPop();
    }
});

var _asg = Catspeak.parseString(_string);
func = Catspeak.compileGML(_asg);

show_debug_message(func());