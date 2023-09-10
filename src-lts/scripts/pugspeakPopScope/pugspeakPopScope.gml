function PugspeakPopScope()
{
    if (global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakPopScope() must only be called whilst a function is executing");
    global.__pugspeakCurrentFunction.popGlobals();
}