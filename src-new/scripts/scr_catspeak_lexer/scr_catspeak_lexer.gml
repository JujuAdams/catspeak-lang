//! Responsible for the lexical analysis stage of the Catspeak compiler.

//# feather use syntax-errors

/// A token in Catspeak is a series of characters with meaning, usually
/// separated by whitespace.
///
/// For example, these are all valid tokens:
///   - `if`   (is a `CatspeakToken.IF`)
///   - `else` (is a `CatspeakToken.ELSE`)
///   - `12.3` (is a `CatspeakToken.VALUE`)
///   - `+`    (is a `CatspeakToken.PLUS`)
///
/// The following enum represents all possible token types understood by the
/// Catspeak language.
enum CatspeakToken {
    /// The `(` character.
    PAREN_LEFT,
    /// The `)` character.
    PAREN_RIGHT,
    /// The `[` character.
    BOX_LEFT,
    /// The `]` character.
    BOX_RIGHT,
    /// The `{` character.
    BRACE_LEFT,
    /// The `}` character.
    BRACE_RIGHT,
    /// The `:` character.
    COLON,
    /// The `,` character.
    COMMA,
    /// The `.` operator.
    DOT,
    /// The `=` operator.
    ASSIGN,
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
    /// The logical `and` operator.
    AND,
    /// The logical `or` operator.
    OR,
    /// The `do` keyword.
    DO,
    /// The `if` keyword.
    IF,
    /// The `else` keyword.
    ELSE,
    /// The `while` keyword.
    WHILE,
    /// The `for` keyword.
    FOR,
    /// The `loop` keyword.
    LOOP,
    /// The `let` keyword.
    LET,
    /// The `fun` keyword.
    FUN,
    /// The `break` keyword.
    BREAK,
    /// The `continue` keyword.
    CONTINUE,
    /// The `return` keyword.
    RETURN,
    /// The `new` keyword.
    NEW,
    /// The `impl` keyword.
    IMPL,
    /// The `self` keyword.
    SELF,
    /// The `params` keyword.
    PARAMS,
    /// Represents a variable name.
    IDENT,
    /// Represents a GML value. This could be one of:
    ///  - string literal:    "hello world"
    ///  - verbatim literal:  @"\(0_0)/ no escapes!"
    ///  - integer:           1, 2, 5
    ///  - float:             1.25, 0.5
    ///  - character:         'A', '0', '\n'
    ///  - boolean:           true or false
    ///  - undefined
    VALUE,
    /// Represents a sequence of non-breaking whitespace characters.
    WHITESPACE,
    /// Represents a comment.
    COMMENT,
    /// Represents a sequence of newline or `;` characters.
    BREAK_LINE,
    /// The `...` operator.
    CONTINUE_LINE,
    /// Represents the end of the file.
    EOF,
    /// Represents any other unrecognised character.
    OTHER,
    __SIZE__
}

/// @ignore
///
/// @param {Any} val
function __catspeak_is_token(val) {
    // the user can modify what keywords are, so just check
    // that they've used one of the enum types instead of a
    // random ass value
    return is_numeric(val) && (
        val >= 0 && val < CatspeakToken.__SIZE__
    );
}

/// @ignore
///
/// @param {String} src
/// @return {Id.Buffer}
function __catspeak_create_buffer_from_string(src) {
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

/// Responsible for tokenising the contents of a GML buffer. This can be used
/// for syntax highlighting in a programming game which uses the Catspeak
/// engine.
///
/// NOTE: The lexer does not take ownership of this buffer, but it may mutate
///       it so beware. Therefore you should make sure to delete the buffer
///       once parsing is complete.
///
/// @param {Id.Buffer} buff
///   The ID of the GML buffer to use.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit
///   will be treated as the end of the file. Defaults to `infinity`.
function CatspeakLexer(buff, offset=0, size=infinity) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
        __catspeak_check_arg("buff", buff, buffer_exists);
        __catspeak_check_arg("offset", offset, is_numeric);
        __catspeak_check_arg("size", size, is_numeric);
    }

    self.buff = buff;
    self.buffAlignment = buffer_get_alignment(buff);
    self.buffCapacity = buffer_get_size(buff);
    self.buffOffset = clamp(offset, 0, self.buffCapacity);
    self.buffSize = clamp(offset + size, 0, self.buffCapacity);
    self.row = 1;
    self.column = 1;
    self.lexemeStart = self.buffOffset;
    self.lexemeEnd = self.lexemeStart;
    self.lexemePos = catspeak_location_create(self.row, self.column);
    self.lexeme = undefined;
    self.value = undefined;
    self.hasValue = false;
    self.peeked = undefined;
    self.charCurr = 0;
    //# feather disable once GM2043
    self.charNext = __nextUTF8Char();
    self.skipNextSemicolon = false;
    self.keywords = global.__catspeakString2Token;

    /// Sets the keyword database for the lexer to use.
    ///
    /// @param {Struct} database
    ///   A struct whose keys map to the corresponding Catspeak tokens they
    ///   represent.
    ///
    /// @return {Struct.CatspeakLexer}
    static withKeywords = function (database) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("database", database, is_struct);
        }

        keywords = database;
        return self;
    };

    /// @ignore
    ///
    /// @return {Real}
    static __nextUTF8Char = function () {
        if (buffOffset >= buffSize) {
            return 0;
        }
        var byte = buffer_peek(buff, buffOffset, buffer_u8);
        buffOffset += 1;
        if ((byte & 0b10000000) == 0) {
            // ASCII digit
            return byte;
        }
        var codepointCount;
        var headerMask;
        // parse UTF8 header, could maybe hand-roll a binary search
        if ((byte & 0b11111100) == 0b11111100) {
            codepointCount = 5;
            headerMask = 0b11111100;
        } else if ((byte & 0b11111000) == 0b11111000) {
            codepointCount = 4;
            headerMask = 0b11111000;
        } else if ((byte & 0b11110000) == 0b11110000) {
            codepointCount = 3;
            headerMask = 0b11110000;
        } else if ((byte & 0b11100000) == 0b11100000) {
            codepointCount = 2;
            headerMask = 0b11100000;
        } else if ((byte & 0b11000000) == 0b11000000) {
            codepointCount = 1;
            headerMask = 0b11000000;
        } else {
            //__catspeak_error("invalid UTF8 header codepoint '", byte, "'");
            return -1;
        }
        // parse UTF8 continuations (2 bit header, followed by 6 bits of data)
        var dataWidth = 6;
        var utf8Value = (byte & ~headerMask) << (codepointCount * dataWidth);
        for (var i = codepointCount - 1; i >= 0; i -= 1) {
            byte = buffer_peek(buff, buffOffset, buffer_u8);
            buffOffset += 1;
            if ((byte & 0b10000000) == 0) {
                //__catspeak_error("invalid UTF8 continuation codepoint '", byte, "'");
                return -1;
            }
            utf8Value |= (byte & ~0b11000000) << (i * dataWidth);
        }
        return utf8Value;
    };

    /// @ignore
    static __advance = function () {
        lexemeEnd = buffOffset;
        if (charNext == ord("\r")) {
            column = 1;
            row += 1;
        } else if (charNext == ord("\n")) {
            column = 1;
            if (charCurr != ord("\r")) {
                row += 1;
            }
        } else {
            column += 1;
        }
        // actually update chars now
        charCurr = charNext;
        charNext = __nextUTF8Char();
    };

    /// @ignore
    static __clearLexeme = function () {
        lexemeStart = lexemeEnd;
        lexemePos = catspeak_location_create(self.row, self.column);
        lexeme = undefined;
        hasValue = false;
    };

    /// @ignore
    ///
    /// @param {Real} start
    /// @param {Real} end_
    static __slice = function (start, end_) {
        var buff_ = buff;
        // don't read outside bounds of `buffSize`
        var clipStart = min(start, buffSize);
        var clipEnd = min(end_, buffSize);
        if (clipEnd <= clipStart) {
            // always an empty slice
            if (CATSPEAK_DEBUG_MODE && clipEnd < clipStart) {
                __catspeak_error_bug();
            }
            return "";
        } else if (clipEnd >= buffCapacity) {
            // beyond the actual capacity of the buffer
            // not safe to use `buffer_string`, which expects a null char
            return buffer_peek(buff_, clipStart, buffer_text);
        } else {
            // quickly write a null terminator and then read the content
            var byte = buffer_peek(buff_, clipEnd, buffer_u8);
            buffer_poke(buff_, clipEnd, buffer_u8, 0x00);
            var result = buffer_peek(buff_, clipStart, buffer_string);
            buffer_poke(buff_, clipEnd, buffer_u8, byte);
            return result;
        }
    };

    /// Returns the string representation of the most recent token emitted by
    /// the [next] or [nextWithWhitespace] methods.
    ///
    /// @example
    ///   Prints the string content of the first [CatspeakToken] emitted by a
    ///   lexer.
    ///
    /// ```gml
    /// lexer.next();
    /// show_debug_message(lexer.getLexeme());
    /// ```
    ///
    /// @return {String}
    static getLexeme = function () {
        lexeme ??= __slice(lexemeStart, lexemeEnd);
        return lexeme;
    };

    /// @ignore
    ///
    /// @param {String} str
    static __getKeyword = function (str) {
        var keyword = keywords[$ str];
        if (CATSPEAK_DEBUG_MODE && keyword != undefined) {
            __catspeak_check_arg(
                    "keyword", keyword, __catspeak_is_token, "CatspeakToken");
        }
        return keyword;
    };

    /// Returns the actual value representation of the most recent token
    /// emitted by the [next] or [nextWithWhitespace] methods.
    ///
    /// NOTE: Unlike [getLexeme] this value is not always a string. For numeric
    ///       literals, the value will be converted into an integer or real.
    ///
    /// @return {Any}
    static getValue = function () {
        if (hasValue) {
            return value;
        }
        value = getLexeme();
        hasValue = true;
        return value;
    };

    /// Returns the location information for the most recent token emitted by
    /// the [next] or [nextWithWhitespace] methods.
    ///
    /// @return {Real}
    static getLocation = function () {
        return catspeak_location_create(row, column);
    };

    /// Advances the lexer and returns the next type of [CatspeakToken]. This
    /// includes additional whitespace and control tokens, like:
    ///  - line breaks `;`          (`CatspeakToken.BREAK_LINE`)
    ///  - line continuations `...` (`CatspeakToken.CONTINUE_LINE`)
    ///  - comments `--`            (`CatspeakToken.COMMENT`)
    ///
    /// To get the string content of the token, you should use the [getLexeme]
    /// method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each non-whitespace token out as a debug message.
    ///
    /// ```gml
    /// var lexer = new CatspeakLexer(buff);
    /// do {
    ///   var token = lexer.nextWithWhitespace();
    ///   if (token != CatspeakToken.WHITESPACE) {
    ///     show_debug_message(lexer.getLexeme());
    ///   }
    /// } until (token == CatspeakToken.EOF);
    /// ```
    ///
    /// @return {Enum.CatspeakToken}
    static nextWithWhitespace = function () {
        __clearLexeme();
        if (charNext == 0) {
            return CatspeakToken.EOF;
        }
        __advance();
        var token = CatspeakToken.OTHER;
        var charCurr_ = charCurr; // micro-optimisation, locals are faster
        if (charCurr_ >= 0 && charCurr_ < __CATSPEAK_CODEPAGE_SIZE) {
            token = global.__catspeakChar2Token[charCurr_];
        }
        if (
            charCurr_ == ord("\"") ||
            charCurr_ == ord("@") && charNext == ord("\"")
        ) {
            // strings
            var isRaw = charCurr_ == ord("@");
            if (isRaw) {
                token = CatspeakToken.VALUE; // since `@` is an operator
                __advance();
            }
            var skipNextChar = false;
            var processEscapes = false;
            while (true) {
                var charNext_ = charNext;
                if (charNext_ == 0) {
                    break;
                }
                if (skipNextChar) {
                    __advance();
                    skipNextChar = false;
                    continue;
                }
                if (!isRaw && charNext == ord("\\")) {
                    skipNextChar = true;
                    processEscapes = true;
                } else if (charNext_ == ord("\"")) {
                    break;
                }
                __advance();
            }
            var value_ = __slice(lexemeStart + (isRaw ? 2 : 1), lexemeEnd);
            if (charNext == ord("\"")) {
                __advance();
            }
            if (processEscapes) {
                // TODO :: may be very slow, figure out how to do it faster
                value_ = string_replace_all(value_, "\\\"", "\"");
                value_ = string_replace_all(value_, "\\t", "\t");
                value_ = string_replace_all(value_, "\\n", "\n");
                value_ = string_replace_all(value_, "\\v", "\v");
                value_ = string_replace_all(value_, "\\f", "\f");
                value_ = string_replace_all(value_, "\\r", "\r");
                value_ = string_replace_all(value_, "\\\\", "\\");
            }
            value = value_;
            hasValue = true;
        } else if (__catspeak_char_is_operator(charCurr_)) {
            // operators
            while (__catspeak_char_is_operator(charNext)) {
                __advance();
            }
            var keyword = __getKeyword(getLexeme());
            if (keyword != undefined) {
                token = keyword;
                if (keyword == CatspeakToken.COMMENT) {
                    // consume the comment
                    lexeme = undefined; // since the lexeme is now invalid
                                        // we have more work to do
                    while (true) {
                        var charNext_ = charNext;
                        if (
                            charNext_ == ord("\n") ||
                            charNext_ == ord("\r") ||
                            charNext_ == 0
                        ) {
                            break;
                        }
                        __advance();
                    }
                }
            }
        } else if (charCurr_ == ord("`")) {
            // literal identifiers
            while (true) {
                var charNext_ = charNext;
                if (
                    charNext_ == ord("`") || charNext_ == 0 ||
                    __catspeak_char_is_whitespace(charNext_)
                ) {
                    break;
                }
                __advance();
            }
            value = __slice(lexemeStart + 1, lexemeEnd);
            hasValue = true;
            if (charNext == ord("`")) {
                __advance();
            }
        } else if (token == CatspeakToken.IDENT) {
            // alphanumeric identifiers
            while (__catspeak_char_is_alphanumeric(charNext)) {
                __advance();
            }
            var lexeme_ = getLexeme();
            var keyword = __getKeyword(lexeme_);
            if (keyword != undefined) {
                token = keyword;
            } else if (lexeme_ == "true") {
                token = CatspeakToken.VALUE;
                value = true;
                hasValue = true;
            } else if (lexeme_ == "false") {
                token = CatspeakToken.VALUE;
                value = false;
                hasValue = true;
            } else if (lexeme_ == "undefined") {
                token = CatspeakToken.VALUE;
                value = undefined;
                hasValue = true;
            }
        } else if (charCurr_ == ord("'")) {
            // character literals
            __advance();
            value = charCurr;
            hasValue = true;
            if (charNext == ord("'")) {
                __advance();
            }
        } else if (token == CatspeakToken.VALUE) {
            // numeric literals
            var hasUnderscores = false;
            var hasDecimal = false;
            while (true) {
                var charNext_ = charNext;
                if (__catspeak_char_is_digit(charNext_)) {
                    __advance();
                } else if (charNext_ == ord("_")) {
                    __advance();
                    hasUnderscores = true;
                } else if (!hasDecimal && charNext_ == ord(".")) {
                    __advance();
                    hasDecimal = true;
                } else {
                    break;
                }
            }
            var digits = getLexeme();
            if (hasUnderscores) {
                digits = string_replace_all(digits, "_", "");
            }
            value = real(digits);
            hasValue = true;
        }
        return token;
    };

    /// Advances the lexer and returns the next [CatspeakToken], ingoring
    /// any comments, whitespace, and line continuations.
    ///
    /// To get the string content of the token, you should use the [getLexeme]
    /// method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each token out as a debug message.
    ///
    /// ```gml
    /// var lexer = new CatspeakLexer(buff);
    /// do {
    ///   var token = lexer.next();
    ///   show_debug_message(lexer.getLexeme());
    /// } until (token == CatspeakToken.EOF);
    /// ```
    ///
    /// @return {Enum.CatspeakToken}
    static next = function () {
        if (peeked != undefined) {
            var token = peeked;
            peeked = undefined;
            return token;
        }
        var skipSemicolon = skipNextSemicolon;
        skipNextSemicolon = false;
        var tokenSkipsNewlinePage = global.__catspeakTokenSkipsNewline;
        while (true) {
            var token = nextWithWhitespace();
            if (token == CatspeakToken.WHITESPACE
                    || token == CatspeakToken.COMMENT) {
                continue;
            }
            if (token == CatspeakToken.CONTINUE_LINE) {
                skipSemicolon = true;
                continue;
            } else if (tokenSkipsNewlinePage[token]) {
                skipNextSemicolon = true;
            }
            if (token == CatspeakToken.BREAK_LINE) {
                if (skipSemicolon) {
                    continue;
                }
                // doing this makes it so that multiple new line characters
                // only count as a single line break token
                skipNextSemicolon = true;
            }
            return token;
        }
    };

    /// Peeks at the next non-whitespace character without advancing the lexer.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each token out as a debug message.
    ///
    /// ```gml
    /// var lexer = new CatspeakLexer(buff);
    /// while (lexer.peek() != CatspeakToken.EOF) {
    ///   lexer.next();
    ///   show_debug_message(lexer.getLexeme());
    /// }
    /// ```
    ///
    /// @return {Enum.CatspeakToken}
    static peek = function () {
        peeked ??= next();
        return peeked;
    };
}

/// @ignore
#macro __CATSPEAK_CODEPAGE_SIZE 256

/// @ignore
function __catspeak_init_lexer() {
    // initialise map from character to token type
    /// @ignore
    global.__catspeakChar2Token = __catspeak_init_lexer_codepage();
    /// @ignore
    global.__catspeakString2Token = __catspeak_init_lexer_keywords();
    /// @ignore
    global.__catspeakTokenSkipsNewline = __catspeak_init_lexer_newlines();
}

/// @ignore
function __catspeak_char_is_digit(char) {
    gml_pragma("forceinline");
    return char >= ord("0") && char <= ord("9");
}

/// @ignore
function __catspeak_char_is_alphanumeric(char) {
    gml_pragma("forceinline");
    return char >= ord("a") && char <= ord("z") ||
            char >= ord("A") && char <= ord("Z") ||
            char >= ord("0") && char <= ord("9") ||
            char == ord("_");
}

/// @ignore
function __catspeak_char_is_operator(char) {
    gml_pragma("forceinline");
    return char >= ord("!") && char <= ord("&") && char != ord("\"") ||
            char >= ord("*") && char <= ord("/") && char != ord(",") ||
            char >= ord(":") && char <= ord("@") ||
            char == ord("\\") || char == ord("^") ||
            char == ord("|") || char == ord("~");
}

/// @ignore
function __catspeak_char_is_whitespace(char) {
    gml_pragma("forceinline");
    return char >= 0x09 && char <= 0x0D || char == 0x20 || char == 0x85;
}

/// @ignore
function __catspeak_codepage_value(code) {
    gml_pragma("forceinline");
    return is_string(code) ? ord(code) : code;
}

/// @ignore
function __catspeak_codepage_range(code, minCode, maxCode) {
    gml_pragma("forceinline");
    var codeVal = __catspeak_codepage_value(code);
    var minVal = __catspeak_codepage_value(minCode);
    var maxVal = __catspeak_codepage_value(maxCode);
    return codeVal >= minVal && codeVal <= maxVal;
}

/// @ignore
function __catspeak_codepage_set(code) {
    gml_pragma("forceinline");
    var codeVal = __catspeak_codepage_value(code);
    for (var i = 1; i < argument_count; i += 1) {
        if (codeVal == __catspeak_codepage_value(argument[i])) {
            return true;
        }
    }
    return false;
}

/// @ignore
function __catspeak_init_lexer_codepage() {
    var page = array_create(__CATSPEAK_CODEPAGE_SIZE, CatspeakToken.OTHER);
    for (var code = 0; code < __CATSPEAK_CODEPAGE_SIZE; code += 1) {
        var tokenType;
        if (__catspeak_codepage_set(code,
            0x09, // CHARACTER TABULATION ('\t')
            0x0B, // LINE TABULATION      ('\v')
            0x0C, // FORM FEED            ('\f')
            0x20, // SPACE                (' ')
            0x85  // NEXT LINE
        )) {
            tokenType = CatspeakToken.WHITESPACE;
        } else if (__catspeak_codepage_set(code,
            0x0A, // LINE FEED            ('\n')
            0x0D  // CARRIAGE RETURN      ('\r')
        )) {
            tokenType = CatspeakToken.BREAK_LINE;
        } else if (
            __catspeak_codepage_range(code, "a", "z") ||
            __catspeak_codepage_range(code, "A", "Z") ||
            __catspeak_codepage_set(code, "_", "`") // identifier literals
        ) {
            tokenType = CatspeakToken.IDENT;
        } else if (
            __catspeak_codepage_range(code, "0", "9") ||
            __catspeak_codepage_set(code, "'") // character literals
        ) {
            tokenType = CatspeakToken.VALUE;
        } else if (__catspeak_codepage_set(code, "\"")) {
            tokenType = CatspeakToken.VALUE;
        } else if (__catspeak_codepage_set(code, "(")) {
            tokenType = CatspeakToken.PAREN_LEFT;
        } else if (__catspeak_codepage_set(code, ")")) {
            tokenType = CatspeakToken.PAREN_RIGHT;
        } else if (__catspeak_codepage_set(code, "[")) {
            tokenType = CatspeakToken.BOX_LEFT;
        } else if (__catspeak_codepage_set(code, "]")) {
            tokenType = CatspeakToken.BOX_RIGHT;
        } else if (__catspeak_codepage_set(code, "{")) {
            tokenType = CatspeakToken.BRACE_LEFT;
        } else if (__catspeak_codepage_set(code, "}")) {
            tokenType = CatspeakToken.BRACE_RIGHT;
        } else if (__catspeak_codepage_set(code, ",")) {
            tokenType = CatspeakToken.COMMA;
        } else {
            continue;
        }
        page[@ code] = tokenType;
    }
    return page;
}

/// Creates a new struct containing all of the default Catspeak keywords.
///
/// @return {Struct}
function catspeak_keywords_create() {
    var keywords = { };
    keywords[$ "--"] = CatspeakToken.COMMENT;
    keywords[$ ";"] = CatspeakToken.BREAK_LINE;
    keywords[$ "..."] = CatspeakToken.CONTINUE_LINE;   
    keywords[$ ":"] = CatspeakToken.COLON;
    keywords[$ ","] = CatspeakToken.COMMA;
    keywords[$ "."] = CatspeakToken.DOT;
    keywords[$ "="] = CatspeakToken.ASSIGN;
    keywords[$ "%"] = CatspeakToken.REMAINDER;
    keywords[$ "*"] = CatspeakToken.MULTIPLY;
    keywords[$ "/"] = CatspeakToken.DIVIDE;
    keywords[$ "//"] = CatspeakToken.DIVIDE_INT;
    keywords[$ "-"] = CatspeakToken.SUBTRACT;
    keywords[$ "+"] = CatspeakToken.PLUS;
    keywords[$ "=="] = CatspeakToken.EQUAL;
    keywords[$ "!="] = CatspeakToken.NOT_EQUAL;
    keywords[$ ">"] = CatspeakToken.GREATER;
    keywords[$ ">="] = CatspeakToken.GREATER_EQUAL;
    keywords[$ "<"] = CatspeakToken.LESS;
    keywords[$ "<="] = CatspeakToken.LESS_EQUAL;
    keywords[$ "!"] = CatspeakToken.NOT;
    keywords[$ "~"] = CatspeakToken.BITWISE_NOT;
    keywords[$ ">>"] = CatspeakToken.SHIFT_RIGHT;
    keywords[$ "<<"] = CatspeakToken.SHIFT_LEFT;
    keywords[$ "&"] = CatspeakToken.BITWISE_AND;
    keywords[$ "^"] = CatspeakToken.BITWISE_XOR;
    keywords[$ "|"] = CatspeakToken.BITWISE_OR;
    keywords[$ "and"] = CatspeakToken.AND;
    keywords[$ "or"] = CatspeakToken.OR;
    keywords[$ "do"] = CatspeakToken.DO;
    keywords[$ "if"] = CatspeakToken.IF;
    keywords[$ "else"] = CatspeakToken.ELSE;
    keywords[$ "while"] = CatspeakToken.WHILE;
    keywords[$ "for"] = CatspeakToken.FOR;
    keywords[$ "loop"] = CatspeakToken.LOOP;
    keywords[$ "let"] = CatspeakToken.LET;
    keywords[$ "fun"] = CatspeakToken.FUN;
    keywords[$ "params"] = CatspeakToken.PARAMS;
    keywords[$ "break"] = CatspeakToken.BREAK;
    keywords[$ "continue"] = CatspeakToken.CONTINUE;
    keywords[$ "return"] = CatspeakToken.RETURN;
    keywords[$ "new"] = CatspeakToken.NEW;
    keywords[$ "impl"] = CatspeakToken.IMPL;
    keywords[$ "self"] = CatspeakToken.SELF;
    return keywords;
}

/// Find the string representation of a [CatspeakToken]. If the token does
/// not appear in the database, then `undefined` is returned instead.
///
/// NOTE: This is an O(n) operation. This means that it's slow, and should
///       only be used for debugging purposes.
///
/// @param {Struct} keywords
///   The keyword database to search.
///
/// @param {Enum.CatspeakToken} token
///   The token type to search for.
///
/// @return {String}
function catspeak_keywords_find_name(keywords, token) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg("keywords", keywords, is_struct);
        __catspeak_check_arg(
                "token", token, __catspeak_is_token, "CatspeakToken");
    }

    var variables = variable_struct_get_names(keywords);
    var variableCount = array_length(variables);
    for (var i = 0; i < variableCount; i += 1) {
        var variable = variables[i];
        if (keywords[$ variable] == token) {
            return variable;
        }
    }
    return undefined;
}

/// Used to change the string representation of a Catspeak keyword.
///
/// @param {Struct} keywords
///   The keyword database to modify.
///
/// @param {String} currentName
///   The current string representation of the keyword to change.
///
/// @param {String} newName
///   The new string representation of the keyword.
function catspeak_keywords_rename(keywords, currentName, newName) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg("keywords", keywords, is_struct);
        __catspeak_check_arg("currentName", currentName, is_string);
        __catspeak_check_arg("newName", newName, is_string);
    }

    if (!variable_struct_exists(keywords, currentName)) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_error(
                "no keyword with the name '", currentName, "' exists"
            );
        }
        return;
    }
    var token = keywords[$ currentName];
    variable_struct_remove(keywords, currentName);
    keywords[$ newName] = token;
}

/// Erases the identity of Catspeak programs by replacing all keywords with
/// GML-adjacent alternatives.
///
/// @param {Struct} keywords
///   The keyword database to modify.
function catspeak_keywords_rename_gml(keywords) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg("keywords", keywords, is_struct);
    }

    catspeak_keywords_rename(keywords, "--", "//");
    catspeak_keywords_rename(keywords, "let", "var");
    catspeak_keywords_rename(keywords, "fun", "function");
    catspeak_keywords_rename(keywords, "impl", "constructor");
    keywords[$ "&&"] = CatspeakToken.AND;
    keywords[$ "||"] = CatspeakToken.OR;
}

/// @ignore
function __catspeak_init_lexer_keywords() {
    var keywords = catspeak_keywords_create();
    global.__catspeakConfig.keywords = keywords;
    return keywords;
}

/// @ignore
function __catspeak_init_lexer_newlines() {
    var page = array_create(CatspeakToken.__SIZE__, false);
    var tokens = [
        // !! DO NOT ADD `BREAK_LINE` HERE, IT WILL RUIN EVERYTHING !!
        //              you have been warned... (*^_^*) b
        CatspeakToken.PAREN_LEFT,
        CatspeakToken.BOX_LEFT,
        CatspeakToken.BRACE_LEFT,
        CatspeakToken.COLON,
        CatspeakToken.COMMA,
        CatspeakToken.DOT,
        CatspeakToken.ASSIGN,
        CatspeakToken.REMAINDER,
        CatspeakToken.MULTIPLY,
        CatspeakToken.DIVIDE,
        CatspeakToken.DIVIDE_INT,
        CatspeakToken.SUBTRACT,
        CatspeakToken.PLUS,
        CatspeakToken.EQUAL,
        CatspeakToken.NOT_EQUAL,
        CatspeakToken.GREATER,
        CatspeakToken.GREATER_EQUAL,
        CatspeakToken.LESS,
        CatspeakToken.LESS_EQUAL,
        CatspeakToken.NOT,
        CatspeakToken.BITWISE_NOT,
        CatspeakToken.SHIFT_RIGHT,
        CatspeakToken.SHIFT_LEFT,
        CatspeakToken.BITWISE_AND,
        CatspeakToken.BITWISE_XOR,
        CatspeakToken.BITWISE_OR,
        CatspeakToken.AND,
        CatspeakToken.OR,
        // this token technically does, but it's handled in a different
        // way to the others, so it's only here honorarily
        //CatspeakToken.CONTINUE_LINE,
        CatspeakToken.DO,
        CatspeakToken.IF,
        CatspeakToken.ELSE,
        CatspeakToken.WHILE,
        CatspeakToken.FOR,
        CatspeakToken.LET,
        CatspeakToken.FUN
    ];
    var count = array_length(tokens);
    for (var i = 0; i < count; i += 1) {
        page[@ tokens[i]] = true;
    }
    return page;
}