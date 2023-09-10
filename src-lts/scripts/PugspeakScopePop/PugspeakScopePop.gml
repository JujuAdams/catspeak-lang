function PugspeakScopePop()
{
    static _global = __PugspeakGMLGlobal();
    if (_global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakScopePop() must only be called whilst a function is executing");
    _global.__pugspeakCurrentFunction.popExecScope();
}