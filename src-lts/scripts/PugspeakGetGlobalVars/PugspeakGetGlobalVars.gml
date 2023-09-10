function PugspeakGetGlobalVars()
{
    static _global = __PugspeakGMLGlobal();
    if (_global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakGetGlobalVars() must only be called whilst a function is executing");
    _global.__pugspeakCurrentFunction.getGlobalVars();
}