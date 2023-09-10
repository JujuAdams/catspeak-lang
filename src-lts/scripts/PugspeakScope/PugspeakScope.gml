function PugspeakScope()
{
    static _global = __PugspeakGlobal();
    if (_global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakPushScope() must only be called whilst a function is executing");
    return _global.__pugspeakCurrentFunction.getExecScope();
}