function PugspeakScope()
{
    if (global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakPushScope() must only be called whilst a function is executing");
    return global.__pugspeakCurrentFunction.getGlobals();
}