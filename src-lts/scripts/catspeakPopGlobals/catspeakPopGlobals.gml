function catspeakPopGlobals()
{
    if (global.__catspeakCurrentFunction == undefined) __catspeak_error("catspeakPopGlobals() must only be called whilst a function is executing");
    global.__catspeakCurrentFunction.popGlobals();
}