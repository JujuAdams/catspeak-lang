function PugspeakScopePush(_target)
{
    static _global = __PugspeakGMLGlobal();
    if (_global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakScopePush() must only be called whilst a function is executing");
    _global.__pugspeakCurrentFunction.pushExecScope(_target);
}