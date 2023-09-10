//! Pugspeak operator database.

//# feather use syntax-errors

/// Represents the set of pure operators used by the Pugspeak runtime and
/// compile-time constant folding.
enum PugspeakOperator {
    /// The remainder `%` operator.
    REMAINDER,
    /// The `*` operator.
    MULTIPLY,
    /// The `/` operator.
    DIVIDE,
    /// The integer division `//` operator.
    DIVIDE_INT,
    /// The `-` operator.
    SUBTRACT,
    /// The `+` operator.
    PLUS,
    /// The `==` operator.
    EQUAL,
    /// The `!=` operator.
    NOT_EQUAL,
    /// The `>` operator.
    GREATER,
    /// The `>=` operator.
    GREATER_EQUAL,
    /// The `<` operator.
    LESS,
    /// The `<=` operator.
    LESS_EQUAL,
    /// The logical negation `!` operator.
    NOT,
    /// The bitwise negation `~` operator.
    BITWISE_NOT,
    /// The bitwise right shift `>>` operator.
    SHIFT_RIGHT,
    /// The bitwise left shift `<<` operator.
    SHIFT_LEFT,
    /// The bitwise and `&` operator.
    BITWISE_AND,
    /// The bitwise xor `^` operator.
    BITWISE_XOR,
    /// The bitwise or `|` operator.
    BITWISE_OR,
    __SIZE__,
}

/// Represents the set of assignment operators understood by Pugspeak.
enum PugspeakAssign {
    /// The typical `=` assignment.
    VANILLA,
    /// Multiply assign `*=`.
    MULTIPLY,
    /// Division assign `/=`.
    DIVIDE,
    /// Subtract assign `-=`.
    SUBTRACT,
    /// Plus assign `+=`.
    PLUS,
    __SIZE__,
}

/// @ignore
///
/// @param {Enum.PugspeakToken} token
/// @return {Enum.PugspeakOperator}
function __pugspeak_operator_from_token(token) {
    return token - PugspeakToken.__OP_BEGIN__ - 1;
}

/// @ignore
///
/// @param {Enum.PugspeakToken} token
/// @return {Enum.PugspeakAssign}
function __pugspeak_operator_assign_from_token(token) {
    return token - PugspeakToken.__OP_ASSIGN_BEGIN__ - 1;
}

/// @ignore
///
/// @param {Enum.PugspeakOperator} op
/// @return {Function}
function __pugspeak_operator_get_binary(op) {
    var opFunc = global.__pugspeakBinOps[op];
    if (PUGSPEAK_DEBUG_MODE && opFunc == undefined) {
        __pugspeak_error_bug();
    }
    return opFunc;
}

/// @ignore
///
/// @param {Enum.PugspeakOperator} op
/// @return {Function}
function __pugspeak_operator_get_unary(op) {
    var opFunc = global.__pugspeakUnaryOps[op];
    if (PUGSPEAK_DEBUG_MODE && opFunc == undefined) {
        __pugspeak_error_bug();
    }
    return opFunc;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_remainder(lhs, rhs) {
    return lhs % rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_multiply(lhs, rhs) {
    return lhs * rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_divide(lhs, rhs) {
    return lhs / rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_divide_int(lhs, rhs) {
    return lhs div rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_subtract(lhs, rhs) {
    return lhs - rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_plus(lhs, rhs) {
    return lhs + rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_equal(lhs, rhs) {
    return lhs == rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_not_equal(lhs, rhs) {
    return lhs != rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_greater(lhs, rhs) {
    return lhs > rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_greater_equal(lhs, rhs) {
    return lhs >= rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_less(lhs, rhs) {
    return lhs < rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_less_equal(lhs, rhs) {
    return lhs <= rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_shift_right(lhs, rhs) {
    return lhs >> rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_shift_left(lhs, rhs) {
    return lhs << rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_bitwise_and(lhs, rhs) {
    return lhs & rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_bitwise_xor(lhs, rhs) {
    return lhs ^ rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_bitwise_or(lhs, rhs) {
    return lhs | rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_subtract_unary(rhs) {
    return -rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_plus_unary(rhs) {
    return +rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_not_unary(rhs) {
    return !rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __pugspeak_op_bitwise_not_unary(rhs) {
    return ~rhs;
}

/// @ignore
function __pugspeak_init_operators() {
    var binOps = array_create(PugspeakOperator.__SIZE__, undefined);
    var unaryOps = array_create(PugspeakOperator.__SIZE__, undefined);
    binOps[@ PugspeakOperator.REMAINDER] = __pugspeak_op_remainder;
    binOps[@ PugspeakOperator.MULTIPLY] = __pugspeak_op_multiply;
    binOps[@ PugspeakOperator.DIVIDE] = __pugspeak_op_divide;
    binOps[@ PugspeakOperator.DIVIDE_INT] = __pugspeak_op_divide_int;
    binOps[@ PugspeakOperator.SUBTRACT] = __pugspeak_op_subtract;
    binOps[@ PugspeakOperator.PLUS] = __pugspeak_op_plus;
    binOps[@ PugspeakOperator.EQUAL] = __pugspeak_op_equal;
    binOps[@ PugspeakOperator.NOT_EQUAL] = __pugspeak_op_not_equal;
    binOps[@ PugspeakOperator.GREATER] = __pugspeak_op_greater;
    binOps[@ PugspeakOperator.GREATER_EQUAL] = __pugspeak_op_greater_equal;
    binOps[@ PugspeakOperator.LESS] = __pugspeak_op_less;
    binOps[@ PugspeakOperator.LESS_EQUAL] = __pugspeak_op_less_equal;
    binOps[@ PugspeakOperator.SHIFT_RIGHT] = __pugspeak_op_shift_right;
    binOps[@ PugspeakOperator.SHIFT_LEFT] = __pugspeak_op_shift_left;
    binOps[@ PugspeakOperator.BITWISE_AND] = __pugspeak_op_bitwise_and;
    binOps[@ PugspeakOperator.BITWISE_XOR] = __pugspeak_op_bitwise_xor;
    binOps[@ PugspeakOperator.BITWISE_OR] = __pugspeak_op_bitwise_or;
    unaryOps[@ PugspeakOperator.SUBTRACT] = __pugspeak_op_subtract_unary;
    unaryOps[@ PugspeakOperator.PLUS] = __pugspeak_op_plus_unary;
    unaryOps[@ PugspeakOperator.NOT] = __pugspeak_op_not_unary;
    unaryOps[@ PugspeakOperator.BITWISE_NOT] = __pugspeak_op_bitwise_not_unary;
    /// @ignore
    global.__pugspeakBinOps = binOps;
    /// @ignore
    global.__pugspeakUnaryOps = unaryOps;
}