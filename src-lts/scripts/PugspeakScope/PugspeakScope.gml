function PugspeakScope()
{
    static _global = __PugspeakGMLGlobal();
    if (_global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakScopePush() must only be called whilst a function is executing");
    return _global.__pugspeakCurrentFunction.getExecScope();
}