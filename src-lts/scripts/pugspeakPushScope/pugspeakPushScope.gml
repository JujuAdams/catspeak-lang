function PugspeakPushScope(_target)
{
    if (global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakPushScope() must only be called whilst a function is executing");
    global.__pugspeakCurrentFunction.pushGlobals(_target);
}