function catspeakPopSelf()
{
    if (global.__catspeakCurrentFunction == undefined) __catspeak_error("catspeakPopSelf() must only be called whilst a function is executing");
    global.__catspeakCurrentFunction.popSelf();
}