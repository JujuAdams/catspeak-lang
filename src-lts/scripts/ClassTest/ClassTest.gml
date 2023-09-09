function ClassTest() constructor
{
    static MethodTest = function(_value)
    {
        show_debug_message(debug_get_callstack());
        show_debug_message("MethodTest says: " + string(_value));
    }
}