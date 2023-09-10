function pugspeakPushGlobals(_target)
{
    if (global.__pugspeakCurrentFunction == undefined) __pugspeak_error("pugspeakPushGlobals() must only be called whilst a function is executing");
    global.__pugspeakCurrentFunction.pushGlobals(_target);
}