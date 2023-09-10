function catspeakPushGlobals(_target)
{
    if (global.__catspeakCurrentFunction == undefined) __catspeak_error("catspeakPushGlobals() must only be called whilst a function is executing");
    global.__catspeakCurrentFunction.pushGlobals(_target);
}