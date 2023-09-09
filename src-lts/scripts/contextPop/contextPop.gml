function contextPop()
{
    var _result = global.context[array_length(global.context)-1];
    array_pop(global.context);
    return _result;
}