function pugspeakPopScope()
{
    if (global.__pugspeakCurrentFunction == undefined) __pugspeak_error("pugspeakPopScope() must only be called whilst a function is executing");
    global.__pugspeakCurrentFunction.popGlobals();
}