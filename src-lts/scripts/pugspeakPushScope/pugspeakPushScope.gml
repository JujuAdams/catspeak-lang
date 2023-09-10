function PugspeakPushScope(_target)
{
    static _global = __PugspeakGlobal();
    if (_global.__pugspeakCurrentFunction == undefined) __pugspeak_error("PugspeakPushScope() must only be called whilst a function is executing");
    _global.__pugspeakCurrentFunction.pushExecScope(_target);
}