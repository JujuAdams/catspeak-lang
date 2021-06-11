/* Catspeak Core Compiler
 * ----------------------
 * Kat @katsaii
 */

/// @desc Represents a kind of token.
enum CatspeakToken {
	PAREN_LEFT,
	PAREN_RIGHT,
	BOX_LEFT,
	BOX_RIGHT,
	BRACE_LEFT,
	BRACE_RIGHT,
	COLON, // function application operator, `f (a + b)` is equivalent to `f : a + b`
	SEMICOLON, // statement terminator
	__OPERATORS_BEGIN__,
	ADDITION,
	__OPERATORS_END__,
	VAR,
	SET,
	IF,
	ELSE,
	WHILE,
	PRINT,
	IDENTIFIER,
	STRING,
	NUMBER,
	WHITESPACE,
	COMMENT,
	EOL,
	BOF,
	EOF,
	OTHER
}

/// @desc Displays the token as a string.
/// @param {CatspeakToken} kind The token kind to display.
function catspeak_token_render(_kind) {
	switch (_kind) {
	case CatspeakToken.PAREN_LEFT: return "PAREN_LEFT";
	case CatspeakToken.PAREN_RIGHT: return "PAREN_RIGHT";
	case CatspeakToken.BOX_LEFT: return "BOX_LEFT";
	case CatspeakToken.BOX_RIGHT: return "BOX_RIGHT";
	case CatspeakToken.BRACE_LEFT: return "BRACE_LEFT";
	case CatspeakToken.BRACE_RIGHT: return "BRACE_RIGHT";
	case CatspeakToken.COLON: return "COLON";
	case CatspeakToken.SEMICOLON: return "SEMICOLON";
	case CatspeakToken.ADDITION: return "ADDITION";
	case CatspeakToken.VAR: return "VAR";
	case CatspeakToken.SET: return "SET";
	case CatspeakToken.IF: return "IF";
	case CatspeakToken.ELSE: return "ELSE";
	case CatspeakToken.WHILE: return "WHILE";
	case CatspeakToken.PRINT: return "PRINT";
	case CatspeakToken.IDENTIFIER: return "IDENTIFIER";
	case CatspeakToken.STRING: return "STRING";
	case CatspeakToken.NUMBER: return "NUMBER";
	case CatspeakToken.WHITESPACE: return "WHITESPACE";
	case CatspeakToken.COMMENT: return "COMMENT";
	case CatspeakToken.EOL: return "EOL";
	case CatspeakToken.BOF: return "BOF";
	case CatspeakToken.EOF: return "EOF";
	case CatspeakToken.OTHER: return "OTHER";
	default: return "<unknown>";
	}
}

/// @desc Returns whether a byte is a valid newline character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_newline(_byte) {
	switch (_byte) {
	case ord("\n"):
	case ord("\r"):
		return true;
	default:
		return false;
	}
}

/// @desc Returns whether a byte is NOT a valid newline character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_not_newline(_byte) {
	return !catspeak_byte_is_newline(_byte);
}

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_quote(_byte) {
	return _byte == ord("\"");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_not_quote(_byte) {
	return !catspeak_byte_is_quote(_byte);
}

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_accent(_byte) {
	return _byte == ord("`");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_not_accent(_byte) {
	return !catspeak_byte_is_accent(_byte);
}

/// @desc Returns whether a byte is a valid whitespace character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_whitespace(_byte) {
	switch (_byte) {
	case ord(" "):
	case ord("\t"):
		return true;
	default:
		return false;
	}
}

/// @desc Returns whether a byte is a valid alphabetic character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_alphabetic(_byte) {
	return _byte >= ord("a") && _byte <= ord("z")
			|| _byte >= ord("A") && _byte <= ord("Z")
			|| _byte == ord("_")
			|| _byte == ord("'");
}

/// @desc Returns whether a byte is a valid digit character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_digit(_byte) {
	return _byte >= ord("0") && _byte <= ord("9");
}

/// @desc Returns whether a byte is a valid alphanumeric character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_alphanumeric(_byte) {
	return catspeak_byte_is_alphabetic(_byte)
			|| catspeak_byte_is_digit(_byte);
}

/// @desc Returns whether a byte is a valid operator character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_operator(_byte) {
	return _byte == ord("!")
			|| _byte >= ord("#") && _byte <= ord("&")
			|| _byte == ord("*")
			|| _byte == ord("+")
			|| _byte == ord("-")
			|| _byte == ord("/")
			|| _byte >= ord("<") && _byte <= ord("@")
			|| _byte == ord("^")
			|| _byte == ord("|")
			|| _byte == ord("~");
}

/// @desc Tokenises the buffer contents.
/// @param {real} buffer The id of the buffer to use.
function CatspeakLexer(_buff) constructor {
	buff = _buff;
	alignment = buffer_get_alignment(_buff);
	limit = buffer_get_size(_buff);
	row = 1; // assumes the buffer is always at its starting position, even if it's not
	col = 1;
	cr = false;
	lexeme = undefined;
	lexemeLength = 0;
	isCommentLexeme = true;
	skipNextByte = false;
	/// @desc Checks for a new line character and increments the source position.
	/// @param {real} byte The byte to register.
	static registerByte = function(_byte) {
		lexemeLength += 1;
		if (isCommentLexeme && _byte != ord("-")) {
			isCommentLexeme = false;
		}
		if (_byte == ord("\r")) {
			cr = true;
			row = 0;
			col += 1;
		} else if (_byte == ord("\n")) {
			row = 0;
			if (cr) {
				cr = false;
			} else {
				col += 1;
			}
		} else {
			row += 1;
			cr = false;
		}
	}
	/// @desc Registers the current lexeme as a string.
	static registerLexeme = function() {
		if (lexemeLength < 1) {
			// always an empty slice
			lexeme = "";
		}
		var slice = buffer_create(lexemeLength, buffer_fixed, 1);
		buffer_copy(buff, buffer_tell(buff) - lexemeLength, lexemeLength, slice, 0);
		buffer_seek(slice, buffer_seek_start, 0);
		lexeme = buffer_read(slice, buffer_text);
		buffer_delete(slice);
	}
	/// @desc Resets the current lexeme.
	static clearLexeme = function() {
		isCommentLexeme = true;
		lexemeLength = 0;
		lexeme = undefined;
	}
	/// @desc Advances the lexer and returns the current byte.
	static advance = function() {
		var byte = buffer_read(buff, buffer_u8);
		registerByte(byte);
		return byte;
	}
	/// @desc Returns whether the next byte equals this expected byte. And advances the lexer if this is the case.
	/// @param {real} expected The byte to check for.
	static advanceIf = function(_expected) {
		var seek = buffer_tell(buff);
		var actual = buffer_peek(buff, seek, buffer_u8);
		if (actual != _expected) {
			return false;
		}
		buffer_read(buff, buffer_u8);
		registerByte(actual);
		return true;
	}
	/// @desc Advances the lexer whilst a predicate holds, or until the EoF was reached.
	/// @param {script} pred The predicate to check for.
	/// @param {script} escape The predicate to check for escapes.
	static advanceWhileEscape = function(_pred, _escape) {
		var do_escape = false;
		var byte = undefined;
		var seek = buffer_tell(buff);
		while (seek < limit) {
			byte = buffer_peek(buff, seek, buffer_u8);
			if (do_escape) {
				do_escape = _escape(byte);
			}
			if not (do_escape) {
				if not (_pred(byte)) {
					break;
				} else if (byte == ord("\\")) {
					do_escape = true;
				}
			}
			registerByte(byte);
			seek += alignment;
		}
		buffer_seek(buff, buffer_seek_start, seek);
		return byte;
	}
	/// @desc Advances the lexer according to this predicate, but escapes newline characters.
	/// @param {script} pred The predicate to check for.
	static advanceWhile = function(_pred) {
		return advanceWhileEscape(_pred, catspeak_byte_is_newline);
	}
	/// @desc Advances the lexer and returns the next token.
	static next = function() {
		if (buffer_tell(buff) >= limit) {
			return CatspeakToken.EOF;
		}
		if (skipNextByte) {
			advance();
			skipNextByte = false;
			return next();
		}
		clearLexeme();
		var byte = advance();
		switch (byte) {
		case ord("\\"):
			// this is needed for a specific case where `\` is the first character in a line
			advanceWhile(catspeak_byte_is_newline);
			advanceWhile(catspeak_byte_is_whitespace);
			return CatspeakToken.WHITESPACE;
		case ord("("):
			return CatspeakToken.PAREN_LEFT;
		case ord(")"):
			return CatspeakToken.PAREN_RIGHT;
		case ord("["):
			return CatspeakToken.BOX_LEFT;
		case ord("]"):
			return CatspeakToken.BOX_RIGHT;
		case ord("{"):
			return CatspeakToken.BRACE_LEFT;
		case ord("}"):
			return CatspeakToken.BRACE_RIGHT;
		case ord(":"):
			return CatspeakToken.COLON;
		case ord(";"):
			return CatspeakToken.SEMICOLON;
		case ord("+"):
		case ord("-"):
			advanceWhile(catspeak_byte_is_operator);
			if (isCommentLexeme && lexemeLength > 1) {
				advanceWhile(catspeak_byte_is_not_newline);
				return CatspeakToken.COMMENT;
			}
			registerLexeme();
			return CatspeakToken.ADDITION;
		case ord("\""):
			clearLexeme();
			advanceWhileEscape(catspeak_byte_is_not_quote, catspeak_byte_is_quote);
			skipNextByte = true;
			registerLexeme();
			return CatspeakToken.STRING;
		case ord("`"):
			clearLexeme();
			advanceWhileEscape(catspeak_byte_is_not_accent, catspeak_byte_is_accent);
			skipNextByte = true;
			registerLexeme();
			return CatspeakToken.IDENTIFIER;
		default:
			if (catspeak_byte_is_newline(byte)) {
				advanceWhile(catspeak_byte_is_newline);
				return CatspeakToken.EOL;
			} else if (catspeak_byte_is_whitespace(byte)) {
				advanceWhile(catspeak_byte_is_whitespace);
				return CatspeakToken.WHITESPACE;
			} else if (catspeak_byte_is_alphabetic(byte)) {
				advanceWhile(catspeak_byte_is_alphanumeric);
				registerLexeme();
				return CatspeakToken.IDENTIFIER;
			} else if (catspeak_byte_is_digit(byte)) {
				advanceWhile(catspeak_byte_is_digit);
				registerLexeme();
				return CatspeakToken.NUMBER;
			} else {
				return CatspeakToken.OTHER;
			}
		}
	}
	/// @desc Returns the next token that isn't a whitespace or comment token.
	static nextWithoutSpace = function() {
		var token;
		do {
			token = next();
		} until (token != CatspeakToken.WHITESPACE
				&& token != CatspeakToken.COMMENT);
		return token;
	}
}

/// @desc Compiles this string and returns the resulting intcode program.
/// @param {string} str The string that contains the source code.
function catspeak_compile(_str) {
	var size = string_byte_length(_str);
	var buff = buffer_create(size, buffer_fixed, 1);
	buffer_write(buff, buffer_text, _str);
	buffer_seek(buff, buffer_seek_start, 0);
	var lexer = new CatspeakLexer(buff);
	var token;
	do {
		token = lexer.nextWithoutSpace();
		show_message([catspeak_token_render(token), lexer.lexeme]);
	} until(token == CatspeakToken.EOF);
	buffer_delete(buff);
}

var src = @'
print : `5` + (-1) -- prints 4
';
var program = catspeak_compile(src);
