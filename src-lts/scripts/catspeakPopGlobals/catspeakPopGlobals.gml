function pugspeakPopGlobals()
{
    if (global.__pugspeakCurrentFunction == undefined) __pugspeak_error("pugspeakPopGlobals() must only be called whilst a function is executing");
    global.__pugspeakCurrentFunction.popGlobals();
}