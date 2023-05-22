
//# feather use syntax-errors

test_add(function() : TestLexerToken("lexer-numbers",
    CatspeakToken.NUMBER, "1", 1
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-2",
    CatspeakToken.NUMBER, "2._", 2
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-3",
    CatspeakToken.NUMBER, "3._4_", 3.4
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-4",
    CatspeakToken.NUMBER, "7_._", 7
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-5",
    CatspeakToken.NUMBER, "5_6_7__", 567
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-char",
    CatspeakToken.NUMBER, "'a'", ord("a")
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-char-2",
    CatspeakToken.NUMBER, "'A'", ord("A")
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-char-3",
    CatspeakToken.NUMBER, "'🙀'", ord("🙀")
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-char-malformed-eof",
    CatspeakToken.NUMBER, "'", 0
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-char-malformed",
    CatspeakToken.NUMBER, "'a'", ord("a")
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-char-malformed-2",
    CatspeakToken.NUMBER, "'A'", ord("A")
) constructor { });

test_add(function() : TestLexerToken("lexer-numbers-char-malformed-3",
    CatspeakToken.NUMBER, "'🙀'", ord("🙀")
) constructor { });