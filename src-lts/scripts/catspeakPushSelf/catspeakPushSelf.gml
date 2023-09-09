function catspeakPushSelf(_target)
{
    if (global.__catspeakCurrentFunction == undefined) __catspeak_error("catspeakPushSelf() must only be called whilst a function is executing");
    global.__catspeakCurrentFunction.pushSelf(_target);
}