// Oniguruma.pas - 2006.11.17
unit Oniguruma;

interface

uses Windows;

const
  ONIGURUMA_VERSION_MAJOR = 4;
  ONIGURUMA_VERSION_MINOR = 5;
  ONIGURUMA_VERSION_TEENY = 1;

type
//* PART: character encoding */
  OnigUChar     = Byte;
  OnigCodePoint = Cardinal;
  OnigDistance  = Cardinal;

//* ambiguous match flag */
  OnigAmbigType = Cardinal;
  TOnigDefaultAmbigFlag = function: OnigAmbigType; cdecl;

const
  ONIGENC_AMBIGUOUS_MATCH_NONE          = 0;
  ONIGENC_AMBIGUOUS_MATCH_ASCII_CASE    = (1 shl 0);
  ONIGENC_AMBIGUOUS_MATCH_NONASCII_CASE = (1 shl 1);

  ONIGENC_AMBIGUOUS_MATCH_LIMIT         = (1 shl 1);

  ONIGENC_AMBIGUOUS_MATCH_FULL = ( ONIGENC_AMBIGUOUS_MATCH_ASCII_CASE or ONIGENC_AMBIGUOUS_MATCH_NONASCII_CASE );

const
  ONIGENC_MAX_COMP_AMBIG_CODE_LEN       = 3;
  ONIGENC_MAX_COMP_AMBIG_CODE_ITEM_NUM  = 4;

type
  OnigCompAmbigCodeItem = record
    len: Integer;
    code: array[0..ONIGENC_MAX_COMP_AMBIG_CODE_LEN-1] of OnigCodePoint;
  end;

  POnigCompAmbigCodes = ^OnigCompAmbigCodes;
  OnigCompAmbigCodes = record
    n: Integer;
    code: OnigCodePoint;
    items: array[0..ONIGENC_MAX_COMP_AMBIG_CODE_ITEM_NUM-1] of OnigCompAmbigCodeItem;
  end;

  POnigPairAmbigCodes = ^OnigPairAmbigCodes;
  OnigPairAmbigCodes = record
    from: OnigCodePoint;
    to_: OnigCodePoint;
  end;

  OnigMetaCharTableType = record
    esc: OnigCodePoint;
    anychar: OnigCodePoint;
    anytime: OnigCodePoint;
    zero_or_one_time: OnigCodePoint;
    one_or_more_time: OnigCodePoint;
    anychar_anytime: OnigCodePoint;
  end;

  POnigUChar = ^OnigUChar;
  POnigCodePoint = ^OnigCodePoint;
  OnigEncodingType = record
    mbc_enc_len: function(p: POnigUChar): Integer;
    enc_name: PChar;
    max_enc_len: Integer;
    min_enc_len: Integer;
    support_ambig_flag: OnigAmbigType;
    meta_char_table: OnigMetaCharTableType;
    is_mbc_newline: function(p, end_: POnigUChar): Integer;
    mbc_to_code: function(const p, end_: POnigUChar): OnigCodePoint;
    code_to_mbclen: function(code: OnigCodePoint): Integer;
    code_to_mbc: function(code: OnigCodePoint; buf: POnigUChar): Integer;
    mbc_to_normalize: function(flag: OnigAmbigType; var pp: POnigUChar; const end_, to_: POnigUChar): Integer;
    is_mbc_ambiguous: function(flag: OnigAmbigType; var pp: POnigUChar; const end_: POnigUChar): Integer;
    get_all_pair_ambig_codes: function(flag: OnigAmbigType; var acs: POnigPairAmbigCodes): Integer;
    get_all_comp_ambig_codes: function(flag: OnigAmbigType; var acs: POnigCompAmbigCodes): Integer;
    is_code_ctype: function(code: OnigCodePoint; ctype: Cardinal): Integer;
    get_ctype_code_range: function(ctype: Integer; const sb_range, mb_range: array of POnigCodePoint): Integer;
    left_adjust_char_head: function(const start, p: POnigUChar): POnigUChar;
    is_allowed_reverse_match: function(const p, end_: POnigUChar): Integer;
  end;

  OnigEncoding = ^OnigEncodingType;

  TOnigEncodingASCII        = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_1   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_2   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_3   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_4   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_5   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_6   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_7   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_8   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_9   = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_10  = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_11  = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_12  = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_13  = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_14  = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_15  = function: OnigEncodingType; cdecl;
  TOnigEncodingISO_8859_16  = function: OnigEncodingType; cdecl;
  TOnigEncodingUTF8         = function: OnigEncodingType; cdecl;
  TOnigEncodingUTF16_BE     = function: OnigEncodingType; cdecl;
  TOnigEncodingUTF16_LE     = function: OnigEncodingType; cdecl;
  TOnigEncodingUTF32_BE     = function: OnigEncodingType; cdecl;
  TOnigEncodingUTF32_LE     = function: OnigEncodingType; cdecl;
  TOnigEncodingEUC_JP       = function: OnigEncodingType; cdecl;
  TOnigEncodingEUC_TW       = function: OnigEncodingType; cdecl;
  TOnigEncodingEUC_KR       = function: OnigEncodingType; cdecl;
  TOnigEncodingEUC_CN       = function: OnigEncodingType; cdecl;
  TOnigEncodingSJIS         = function: OnigEncodingType; cdecl;
  TOnigEncodingKOI8         = function: OnigEncodingType; cdecl;
  TOnigEncodingKOI8_R       = function: OnigEncodingType; cdecl;
  TOnigEncodingBIG5         = function: OnigEncodingType; cdecl;
  TOnigEncodingGB18030      = function: OnigEncodingType; cdecl;

var
  ONIG_ENCODING_ASCII:        TOnigEncodingASCII;
  ONIG_ENCODING_ISO_8859_1:   TOnigEncodingISO_8859_1;
  ONIG_ENCODING_ISO_8859_2:   TOnigEncodingISO_8859_2;
  ONIG_ENCODING_ISO_8859_3:   TOnigEncodingISO_8859_3;
  ONIG_ENCODING_ISO_8859_4:   TOnigEncodingISO_8859_4;
  ONIG_ENCODING_ISO_8859_5:   TOnigEncodingISO_8859_5;
  ONIG_ENCODING_ISO_8859_6:   TOnigEncodingISO_8859_6;
  ONIG_ENCODING_ISO_8859_7:   TOnigEncodingISO_8859_7;
  ONIG_ENCODING_ISO_8859_8:   TOnigEncodingISO_8859_8;
  ONIG_ENCODING_ISO_8859_9:   TOnigEncodingISO_8859_9;
  ONIG_ENCODING_ISO_8859_10:  TOnigEncodingISO_8859_10;
  ONIG_ENCODING_ISO_8859_11:  TOnigEncodingISO_8859_11;
  ONIG_ENCODING_ISO_8859_13:  TOnigEncodingISO_8859_13;
  ONIG_ENCODING_ISO_8859_14:  TOnigEncodingISO_8859_14;
  ONIG_ENCODING_ISO_8859_15:  TOnigEncodingISO_8859_15;
  ONIG_ENCODING_ISO_8859_16:  TOnigEncodingISO_8859_16;
  ONIG_ENCODING_UTF8:         TOnigEncodingUTF8;
  ONIG_ENCODING_UTF16_BE:     TOnigEncodingUTF16_BE;
  ONIG_ENCODING_UTF16_LE:     TOnigEncodingUTF16_LE;
  ONIG_ENCODING_UTF32_BE:     TOnigEncodingUTF32_BE;
  ONIG_ENCODING_UTF32_LE:     TOnigEncodingUTF32_LE;
  ONIG_ENCODING_EUC_JP:       TOnigEncodingEUC_JP;
  ONIG_ENCODING_EUC_TW:       TOnigEncodingEUC_TW;
  ONIG_ENCODING_EUC_KR:       TOnigEncodingEUC_KR;
  ONIG_ENCODING_EUC_CN:       TOnigEncodingEUC_CN;
  ONIG_ENCODING_SJIS:         TOnigEncodingSJIS;
  ONIG_ENCODING_KOI8:         TOnigEncodingKOI8;
  ONIG_ENCODING_KOI8_R:       TOnigEncodingKOI8_R;
  ONIG_ENCODING_BIG5:         TOnigEncodingBIG5;
  ONIG_ENCODING_GB18030:      TOnigEncodingGB18030;

const
  ONIG_ENCODING_UNDEF = OnigEncoding(0);

//* work size */
  ONIGENC_CODE_TO_MBC_MAXLEN    = 7;
  ONIGENC_MBC_NORMALIZE_MAXLEN  = ONIGENC_CODE_TO_MBC_MAXLEN;

//* character types */
  ONIGENC_CTYPE_NEWLINE = (1 shl 0);
  ONIGENC_CTYPE_ALPHA   = (1 shl 1);
  ONIGENC_CTYPE_BLANK   = (1 shl 2);
  ONIGENC_CTYPE_CNTRL   = (1 shl 3);
  ONIGENC_CTYPE_DIGIT   = (1 shl 4);
  ONIGENC_CTYPE_GRAPH   = (1 shl 5);
  ONIGENC_CTYPE_LOWER   = (1 shl 6);
  ONIGENC_CTYPE_PRINT   = (1 shl 7);
  ONIGENC_CTYPE_PUNCT   = (1 shl 8);
  ONIGENC_CTYPE_SPACE   = (1 shl 9);
  ONIGENC_CTYPE_UPPER   = (1 shl 10);
  ONIGENC_CTYPE_XDIGIT  = (1 shl 11);
  ONIGENC_CTYPE_WORD    = (1 shl 12);
  ONIGENC_CTYPE_ASCII   = (1 shl 13);
  ONIGENC_CTYPE_ALNUM   = (ONIGENC_CTYPE_ALPHA or ONIGENC_CTYPE_DIGIT);

type
  Tonigenc_step_back = function(enc: OnigEncoding; const start, s: POnigUChar; n: Integer): POnigUChar; cdecl;

//* encoding API */
  Tonigenc_init                                 = function: Integer; cdecl;
  Tonigenc_set_default_encoding                 = function(enc: OnigEncoding): Integer; cdecl;
  Tonigenc_get_default_encoding                 = function: OnigEncoding; cdecl;
  Tonigenc_set_default_caseconv_table           = procedure (const table: POnigUChar); cdecl;
  Tonigenc_get_right_adjust_char_head_with_prev = function(enc: OnigEncoding; const start, s: POnigUChar; var prev: POnigUChar): POnigUChar; cdecl;
  Tonigenc_get_prev_char_head                   = function(enc: OnigEncoding; const start, s: POnigUChar): POnigUChar; cdecl;
  Tonigenc_get_left_adjust_char_head            = function(enc: OnigEncoding; const start, s: POnigUChar): POnigUChar; cdecl;
  Tonigenc_get_right_adjust_char_head           = function(enc: OnigEncoding; const start, s: POnigUChar): POnigUChar; cdecl;
  Tonigenc_strlen                               = function(enc: OnigEncoding; const p, str_end: POnigUChar): Integer; cdecl;
  Tonigenc_strlen_null                          = function(enc: OnigEncoding; const p: POnigUChar): Integer; cdecl;
  Tonigenc_str_bytelen_null                     = function (enc: OnigEncoding; const p: POnigUChar): Integer; cdecl;

var
  onigenc_init:                                   Tonigenc_init;
  onigenc_set_default_encoding:                   Tonigenc_set_default_encoding;
  onigenc_get_default_encoding:                   Tonigenc_get_default_encoding;
  onigenc_set_default_caseconv_table:             Tonigenc_set_default_caseconv_table;
  onigenc_get_right_adjust_char_head_with_prev:   Tonigenc_get_right_adjust_char_head_with_prev;
  onigenc_get_prev_char_head:                     Tonigenc_get_prev_char_head;
  onigenc_get_left_adjust_char_head:              Tonigenc_get_left_adjust_char_head;
  onigenc_get_right_adjust_char_head:             Tonigenc_get_right_adjust_char_head;
  onigenc_strlen:                                 Tonigenc_strlen;
  onigenc_strlen_null:                            Tonigenc_strlen_null;
  onigenc_str_bytelen_null:                       Tonigenc_str_bytelen_null;

//* PART: regular expression */

const
//* config parameters */
  ONIG_NREGION                    =     10;
  ONIG_MAX_BACKREF_NUM            =   1000;
  ONIG_MAX_REPEAT_NUM             = 100000;
  ONIG_MAX_MULTI_BYTE_RANGES_NUM  =  10000;
//* constants */
  ONIG_MAX_ERROR_MESSAGE_LEN      =     90;

type
  OnigOptionType = Cardinal;

const
//* options */
  ONIG_OPTION_NONE                = 0;
  ONIG_OPTION_IGNORECASE          = 1;
  ONIG_OPTION_EXTEND              = (ONIG_OPTION_IGNORECASE         shl 1);
  ONIG_OPTION_MULTILINE           = (ONIG_OPTION_EXTEND             shl 1);
  ONIG_OPTION_SINGLELINE          = (ONIG_OPTION_MULTILINE          shl 1);
  ONIG_OPTION_FIND_LONGEST        = (ONIG_OPTION_SINGLELINE         shl 1);
  ONIG_OPTION_FIND_NOT_EMPTY      = (ONIG_OPTION_FIND_LONGEST       shl 1);
  ONIG_OPTION_NEGATE_SINGLELINE   = (ONIG_OPTION_FIND_NOT_EMPTY     shl 1);
  ONIG_OPTION_DONT_CAPTURE_GROUP  = (ONIG_OPTION_NEGATE_SINGLELINE  shl 1);
  ONIG_OPTION_CAPTURE_GROUP       = (ONIG_OPTION_DONT_CAPTURE_GROUP  shl 1);

  ONIG_OPTION_DEFAULT             = ONIG_OPTION_NONE;

//* options (search time) */
  ONIG_OPTION_NOTBOL              = (ONIG_OPTION_CAPTURE_GROUP shl 1);
  ONIG_OPTION_NOTEOL              = (ONIG_OPTION_NOTBOL        shl 1);
  ONIG_OPTION_POSIX_REGION        = (ONIG_OPTION_NOTEOL        shl 1);
  ONIG_OPTION_MAXBIT              = ONIG_OPTION_POSIX_REGION; //* limit */

type
//* syntax */
  POnigSyntaxType = ^OnigSyntaxType;
  OnigSyntaxType = record
    op: Cardinal;
    op2: Cardinal;
    behavior: Cardinal;
    options: OnigOptionType; //* default option */
  end;

  TOnigSyntaxASIS           = function: OnigSyntaxType; cdecl;
  TOnigSyntaxPosixBasic     = function: OnigSyntaxType; cdecl;
  TOnigSyntaxPosixExtended  = function: OnigSyntaxType; cdecl;
  TOnigSyntaxEmacs          = function: OnigSyntaxType; cdecl;
  TOnigSyntaxGrep           = function: OnigSyntaxType; cdecl;
  TOnigSyntaxGnuRegex       = function: OnigSyntaxType; cdecl;
  TOnigSyntaxJava           = function: OnigSyntaxType; cdecl;
  TOnigSyntaxPerl           = function: OnigSyntaxType; cdecl;
  TOnigSyntaxPerl_NG        = function: OnigSyntaxType; cdecl;
  TOnigSyntaxRuby           = function: OnigSyntaxType; cdecl;

var
//* predefined syntaxes (see regsyntax.c) */
  ONIG_SYNTAX_ASIS:           TOnigSyntaxASIS;
  ONIG_SYNTAX_POSIX_BASIC:    TOnigSyntaxPosixBasic;
  ONIG_SYNTAX_POSIX_EXTENDED: TOnigSyntaxPosixExtended;
  ONIG_SYNTAX_EMACS:          TOnigSyntaxEmacs;
  ONIG_SYNTAX_GREP:           TOnigSyntaxGrep;
  ONIG_SYNTAX_GNU_REGEX:      TOnigSyntaxGnuRegex;
  ONIG_SYNTAX_JAVA:           TOnigSyntaxJava;
  ONIG_SYNTAX_PERL:           TOnigSyntaxPerl;
  ONIG_SYNTAX_PERL_NG:        TOnigSyntaxPerl_NG;
  ONIG_SYNTAX_RUBY:           TOnigSyntaxRuby;

type
//* default syntax */
  TOnigDefaultSyntax = function: POnigSyntaxType; cdecl;
var
  ONIG_SYNTAX_DEFAULT: TOnigDefaultSyntax;

const
//* syntax (operators) */
  ONIG_SYN_OP_VARIABLE_META_CHARACTERS    = (1 shl 0);
  ONIG_SYN_OP_DOT_ANYCHAR                 = (1 shl 1);   //* . */
  ONIG_SYN_OP_ASTERISK_ZERO_INF           = (1 shl 2);   //* * */
  ONIG_SYN_OP_ESC_ASTERISK_ZERO_INF       = (1 shl 3);
  ONIG_SYN_OP_PLUS_ONE_INF                = (1 shl 4);   //* + */
  ONIG_SYN_OP_ESC_PLUS_ONE_INF            = (1 shl 5);
  ONIG_SYN_OP_QMARK_ZERO_ONE              = (1 shl 6);   //* ? */
  ONIG_SYN_OP_ESC_QMARK_ZERO_ONE          = (1 shl 7);
  ONIG_SYN_OP_BRACE_INTERVAL              = (1 shl 8);   //* {lower,upper} */
  ONIG_SYN_OP_ESC_BRACE_INTERVAL          = (1 shl 9);   //* \{lower,upper\} */
  ONIG_SYN_OP_VBAR_ALT                    = (1 shl 10);  //* | */
  ONIG_SYN_OP_ESC_VBAR_ALT                = (1 shl 11);  //* \| */
  ONIG_SYN_OP_LPAREN_SUBEXP               = (1 shl 12);  //* (...)   */
  ONIG_SYN_OP_ESC_LPAREN_SUBEXP           = (1 shl 13);  //* \(...\) */
  ONIG_SYN_OP_ESC_AZ_BUF_ANCHOR           = (1 shl 14);  //* \A, \Z, \z */
  ONIG_SYN_OP_ESC_CAPITAL_G_BEGIN_ANCHOR  = (1 shl 15);  //* \G     */
  ONIG_SYN_OP_DECIMAL_BACKREF             = (1 shl 16);  //* \num   */
  ONIG_SYN_OP_BRACKET_CC                  = (1 shl 17);  //* [...]  */
  ONIG_SYN_OP_ESC_W_WORD                  = (1 shl 18);  //* \w, \W */
  ONIG_SYN_OP_ESC_LTGT_WORD_BEGIN_END     = (1 shl 19);  //* \<. \> */
  ONIG_SYN_OP_ESC_B_WORD_BOUND            = (1 shl 20);  //* \b, \B */
  ONIG_SYN_OP_ESC_S_WHITE_SPACE           = (1 shl 21);  //* \s, \S */
  ONIG_SYN_OP_ESC_D_DIGIT                 = (1 shl 22);  //* \d, \D */
  ONIG_SYN_OP_LINE_ANCHOR                 = (1 shl 23);  //* ^, $   */
  ONIG_SYN_OP_POSIX_BRACKET               = (1 shl 24);  //* [:xxxx:] */
  ONIG_SYN_OP_QMARK_NON_GREEDY            = (1 shl 25);  //* ??,*?,+?,{n,m}? */
  ONIG_SYN_OP_ESC_CONTROL_CHARS           = (1 shl 26);  //* \n,\r,\t,\a ... */
  ONIG_SYN_OP_ESC_C_CONTROL               = (1 shl 27);  //* \cx  */
  ONIG_SYN_OP_ESC_OCTAL3                  = (1 shl 28);  //* \OOO */
  ONIG_SYN_OP_ESC_X_HEX2                  = (1 shl 29);  //* \xHH */
  ONIG_SYN_OP_ESC_X_BRACE_HEX8            = (1 shl 30);  //* \x{7HHHHHHH} */

  ONIG_SYN_OP2_ESC_CAPITAL_Q_QUOTE        = (1 shl 0);   //* \Q...\E */
  ONIG_SYN_OP2_QMARK_GROUP_EFFECT         = (1 shl 1);   //* (?...) */
  ONIG_SYN_OP2_OPTION_PERL                = (1 shl 2);   //* (?imsx),(?-imsx) */
  ONIG_SYN_OP2_OPTION_RUBY                = (1 shl 3);   //* (?imx), (?-imx)  */
  ONIG_SYN_OP2_PLUS_POSSESSIVE_REPEAT     = (1 shl 4);   //* ?+,*+,++ */
  ONIG_SYN_OP2_PLUS_POSSESSIVE_INTERVAL   = (1 shl 5);   //* {n,m}+   */
  ONIG_SYN_OP2_CCLASS_SET_OP              = (1 shl 6);   //* [...&&..[..]..] */
  ONIG_SYN_OP2_QMARK_LT_NAMED_GROUP       = (1 shl 7);   //* (?<name>...) */
  ONIG_SYN_OP2_ESC_K_NAMED_BACKREF        = (1 shl 8);   //* \k<name> */
  ONIG_SYN_OP2_ESC_G_SUBEXP_CALL          = (1 shl 9);   //* \g<name>, \g<n> */
  ONIG_SYN_OP2_ATMARK_CAPTURE_HISTORY     = (1 shl 10);  //* (?@..),(?@<x>..) */
  ONIG_SYN_OP2_ESC_CAPITAL_C_BAR_CONTROL  = (1 shl 11);  //* \C-x */
  ONIG_SYN_OP2_ESC_CAPITAL_M_BAR_META     = (1 shl 12);  //* \M-x */
  ONIG_SYN_OP2_ESC_V_VTAB                 = (1 shl 13);  //* \v as VTAB */
  ONIG_SYN_OP2_ESC_U_HEX4                 = (1 shl 14);  //* \uHHHH */
  ONIG_SYN_OP2_ESC_GNU_BUF_ANCHOR         = (1 shl 15);  //* \`, \' */
  ONIG_SYN_OP2_ESC_P_BRACE_CHAR_PROPERTY  = (1 shl 16);  //* \p{...}, \P{...} */
  ONIG_SYN_OP2_ESC_P_BRACE_CIRCUMFLEX_NOT = (1 shl 17);  //* \p{^..}, \P{^..} */
  ONIG_SYN_OP2_CHAR_PROPERTY_PREFIX_IS    = (1 shl 18);  //* \p{IsXDigit} */
  ONIG_SYN_OP2_ESC_H_XDIGIT               = (1 shl 19);  //* \h, \H */
  ONIG_SYN_OP2_INEFFECTIVE_ESCAPE         = (1 shl 20);  //* \ */

//* syntax (behavior) */
  ONIG_SYN_CONTEXT_INDEP_ANCHORS          = (1 shl 31);  //* not implemented */
  ONIG_SYN_CONTEXT_INDEP_REPEAT_OPS       = (1 shl 0);   //* ?, *, +, {n,m} */
  ONIG_SYN_CONTEXT_INVALID_REPEAT_OPS     = (1 shl 1);   //* error or ignore */
  ONIG_SYN_ALLOW_UNMATCHED_CLOSE_SUBEXP   = (1 shl 2);   //* ...)... */
  ONIG_SYN_ALLOW_INVALID_INTERVAL         = (1 shl 3);   //* {??? */
  ONIG_SYN_ALLOW_INTERVAL_LOW_ABBREV      = (1 shl 4);   //* {,n} => {0,n} */
  ONIG_SYN_STRICT_CHECK_BACKREF           = (1 shl 5);   //* /(\1)/,/\1()/ ..*/
  ONIG_SYN_DIFFERENT_LEN_ALT_LOOK_BEHIND  = (1 shl 6);   //* (?<=a|bc) */
  ONIG_SYN_CAPTURE_ONLY_NAMED_GROUP       = (1 shl 7);   //* see doc/RE */
  ONIG_SYN_ALLOW_MULTIPLEX_DEFINITION_NAME= (1 shl 8);   //* (?<x>)(?<x>) */
  ONIG_SYN_FIXED_INTERVAL_IS_GREEDY_ONLY  = (1 shl 9);   //* a{n}?=(?:a{n})? */

//* syntax (behavior) in char class [...] */
  ONIG_SYN_NOT_NEWLINE_IN_NEGATIVE_CC     = (1 shl 20);  //* [^...] */
  ONIG_SYN_BACKSLASH_ESCAPE_IN_CC         = (1 shl 21);  //* [..\w..] etc.. */
  ONIG_SYN_ALLOW_EMPTY_RANGE_IN_CC        = (1 shl 22);
  ONIG_SYN_ALLOW_DOUBLE_RANGE_OP_IN_CC    = (1 shl 23);  //* [0-9-a]=[0-9\-a] */
//* syntax (behavior) warning */
  ONIG_SYN_WARN_CC_OP_NOT_ESCAPED         = (1 shl 24);  //* [,-,] */
  ONIG_SYN_WARN_REDUNDANT_NESTED_REPEAT   = (1 shl 25);  //* (?:a*)+ */

//* meta character specifiers (onig_set_meta_char()) */
  ONIG_META_CHAR_ESCAPE           = 0;
  ONIG_META_CHAR_ANYCHAR          = 1;
  ONIG_META_CHAR_ANYTIME          = 2;
  ONIG_META_CHAR_ZERO_OR_ONE_TIME = 3;
  ONIG_META_CHAR_ONE_OR_MORE_TIME = 4;
  ONIG_META_CHAR_ANYCHAR_ANYTIME  = 5;

  ONIG_INEFFECTIVE_META_CHAR      = 0;

  function ONIG_IS_PATTERN_ERROR(ecode: Integer): Boolean;

const
//* normal return */
  ONIG_NORMAL                                           =     0;
  ONIG_MISMATCH                                         =    -1;
  ONIG_NO_SUPPORT_CONFIG                                =    -2;

//* internal error */
  ONIGERR_MEMORY                                        =    -5;
  ONIGERR_TYPE_BUG                                      =    -6;
  ONIGERR_PARSER_BUG                                    =   -11;
  ONIGERR_STACK_BUG                                     =   -12;
  ONIGERR_UNDEFINED_BYTECODE                            =   -13;
  ONIGERR_UNEXPECTED_BYTECODE                           =   -14;
  ONIGERR_MATCH_STACK_LIMIT_OVER                        =   -15;
  ONIGERR_DEFAULT_ENCODING_IS_NOT_SETTED                =   -21;
  ONIGERR_SPECIFIED_ENCODING_CANT_CONVERT_TO_WIDE_CHAR  =   -22;
//* general error */
  ONIGERR_INVALID_ARGUMENT                              =   -30;
//* syntax error */
  ONIGERR_END_PATTERN_AT_LEFT_BRACE                     =  -100;
  ONIGERR_END_PATTERN_AT_LEFT_BRACKET                   =  -101;
  ONIGERR_EMPTY_CHAR_CLASS                              =  -102;
  ONIGERR_PREMATURE_END_OF_CHAR_CLASS                   =  -103;
  ONIGERR_END_PATTERN_AT_ESCAPE                         =  -104;
  ONIGERR_END_PATTERN_AT_META                           =  -105;
  ONIGERR_END_PATTERN_AT_CONTROL                        =  -106;
  ONIGERR_META_CODE_SYNTAX                              =  -108;
  ONIGERR_CONTROL_CODE_SYNTAX                           =  -109;
  ONIGERR_CHAR_CLASS_VALUE_AT_END_OF_RANGE              =  -110;
  ONIGERR_CHAR_CLASS_VALUE_AT_START_OF_RANGE            =  -111;
  ONIGERR_UNMATCHED_RANGE_SPECIFIER_IN_CHAR_CLASS       =  -112;
  ONIGERR_TARGET_OF_REPEAT_OPERATOR_NOT_SPECIFIED       =  -113;
  ONIGERR_TARGET_OF_REPEAT_OPERATOR_INVALID             =  -114;
  ONIGERR_NESTED_REPEAT_OPERATOR                        =  -115;
  ONIGERR_UNMATCHED_CLOSE_PARENTHESIS                   =  -116;
  ONIGERR_END_PATTERN_WITH_UNMATCHED_PARENTHESIS        =  -117;
  ONIGERR_END_PATTERN_IN_GROUP                          =  -118;
  ONIGERR_UNDEFINED_GROUP_OPTION                        =  -119;
  ONIGERR_INVALID_POSIX_BRACKET_TYPE                    =  -121;
  ONIGERR_INVALID_LOOK_BEHIND_PATTERN                   =  -122;
  ONIGERR_INVALID_REPEAT_RANGE_PATTERN                  =  -123;
//* values error (syntax error) */
  ONIGERR_TOO_BIG_NUMBER                                =  -200;
  ONIGERR_TOO_BIG_NUMBER_FOR_REPEAT_RANGE               =  -201;
  ONIGERR_UPPER_SMALLER_THAN_LOWER_IN_REPEAT_RANGE      =  -202;
  ONIGERR_EMPTY_RANGE_IN_CHAR_CLASS                     =  -203;
  ONIGERR_MISMATCH_CODE_LENGTH_IN_CLASS_RANGE           =  -204;
  ONIGERR_TOO_MANY_MULTI_BYTE_RANGES                    =  -205;
  ONIGERR_TOO_SHORT_MULTI_BYTE_STRING                   =  -206;
  ONIGERR_TOO_BIG_BACKREF_NUMBER                        =  -207;
  ONIGERR_INVALID_BACKREF                               =  -208;
  ONIGERR_NUMBERED_BACKREF_OR_CALL_NOT_ALLOWED          =  -209;
  ONIGERR_TOO_LONG_WIDE_CHAR_VALUE                      =  -212;
  ONIGERR_EMPTY_GROUP_NAME                              =  -214;
  ONIGERR_INVALID_GROUP_NAME                            =  -215;
  ONIGERR_INVALID_CHAR_IN_GROUP_NAME                    =  -216;
  ONIGERR_UNDEFINED_NAME_REFERENCE                      =  -217;
  ONIGERR_UNDEFINED_GROUP_REFERENCE                     =  -218;
  ONIGERR_MULTIPLEX_DEFINED_NAME                        =  -219;
  ONIGERR_MULTIPLEX_DEFINITION_NAME_CALL                =  -220;
  ONIGERR_NEVER_ENDING_RECURSION                        =  -221;
  ONIGERR_GROUP_NUMBER_OVER_FOR_CAPTURE_HISTORY         =  -222;
  ONIGERR_INVALID_CHAR_PROPERTY_NAME                    =  -223;
  ONIGERR_INVALID_WIDE_CHAR_VALUE                       =  -400;
  ONIGERR_TOO_BIG_WIDE_CHAR_VALUE                       =  -401;
  ONIGERR_NOT_SUPPORTED_ENCODING_COMBINATION            =  -402;
  ONIGERR_INVALID_COMBINATION_OF_OPTIONS                =  -403;

//* errors related to thread */
  ONIGERR_OVER_THREAD_PASS_LIMIT_COUNT                  = -1001;

//* must be smaller than BIT_STATUS_BITS_NUM (unsigned int * 8) */
  ONIG_MAX_CAPTURE_HISTORY_GROUP = 31;

type
  PPOnigCaptureTreeNode = ^POnigCaptureTreeNode;
  POnigCaptureTreeNode= ^OnigCaptureTreeNode;
  OnigCaptureTreeNode = record
    group: Integer;	//* group number */
    match_beg: Integer;
    match_end: Integer;
    allocated: Integer;
    num_childs: Integer;
    childs: PPOnigCaptureTreeNode;
  end;

//* match result region type */
  POnigRegion = ^OnigRegion;
  OnigRegion = record
    allocated: Integer;
    num_regs: Integer;
    match_beg: PInteger;
    match_end: PInteger;
    //* extended */
    history_root: POnigCaptureTreeNode;  //* capture history tree root */
  end;

const
//* capture tree traverse */
  ONIG_TRAVERSE_CALLBACK_AT_FIRST = 1;
  ONIG_TRAVERSE_CALLBACK_AT_LAST  = 2;
  ONIG_TRAVERSE_CALLBACK_AT_BOTH  = ( ONIG_TRAVERSE_CALLBACK_AT_FIRST or
                                      ONIG_TRAVERSE_CALLBACK_AT_LAST );

  ONIG_REGION_NOTPOS = -1;

type

  POnigErrorInfo = ^OnigErrorInfo;
  OnigErrorInfo = record
    enc: OnigEncoding;
    par: POnigUChar;
    par_end: POnigUChar;
  end;

  POnigRepeatRange = ^OnigRepeatRange;
  OnigRepeatRange = record
    lower: Integer;
    upper: Integer;
  end;

  TOnigWarnFunc = procedure (const s: PChar); cdecl;

type
  Tonig_null_warn = procedure(const s: PChar); cdecl;
  ONIG_NULL_WARN  = Tonig_null_warn;

const
  ONIG_CHAR_TABLE_SIZE  = 256;

//* regex_t state */
  ONIG_STATE_NORMAL     =   0;
  ONIG_STATE_SEARCHING  =   1;
  ONIG_STATE_COMPILING  =  -1;
  ONIG_STATE_MODIFY     =  -2;

type

  POnigRegexType = ^OnigRegexType;
  OnigRegexType = record
    //* common members of BBuf(bytes-buffer) */
    p: PByte;         //* compiled pattern */
    used: Cardinal;   //* used space for p */
    alloc: Cardinal;  //* allocated space for p */

    state: Integer;             //* normal, searching, compiling */
    num_mem: Integer;           //* used memory(...) num counted from 1 */
    num_repeat: Integer;        //* OP_REPEAT/OP_REPEAT_NG id-counter */
    num_null_check: Integer;    //* OP_NULL_CHECK_START/END id counter */
    num_comb_exp_check: Integer;//* combination explosion check */
    num_call: Integer;          //* number of subexp call */
    capture_history: Cardinal;  //* (?@...) flag (1-31) */
    bt_mem_start: Cardinal;     //* need backtrack flag */
    bt_mem_end: Cardinal;       //* need backtrack flag */
    stack_pop_level: Integer;
    repeat_range_alloc: Integer;
    repeat_range: POnigRepeatRange;

    enc: OnigEncoding;
    options: OnigOptionType;
    syntax: POnigSyntaxType;
    ambig_flag: OnigAmbigType;
    name_table: Pointer;

    //* optimization info (string search, char-map and anchors) */
    optimize: Integer;          //* optimize flag */
    threshold_len: Integer;     //* search str-length for apply optimize */
    anchor: Integer;            //* BEGIN_BUF, BEGIN_POS, (SEMI_)END_BUF */
    anchor_dmin: OnigDistance;  //* (SEMI_)END_BUF anchor distance */
    anchor_dmax: OnigDistance;  //* (SEMI_)END_BUF anchor distance */
    sub_anchor: Integer;        //* start-anchor for exact or map */
    exact: PByte;
    exact_end: PByte;
    map: array[0..ONIG_CHAR_TABLE_SIZE-1]of Byte; //* used as BM skip or char-map */
    int_map: PInteger;                            //* BM skip for exact_len > 255 */
    int_map_backward: PInteger;                   //* BM skip for backward search */
    dmin: OnigDistance;                           //* min-distance of exact or map */
    dmax: OnigDistance;                           //* max-distance of exact or map */

    //* regex_t link chain */
    chain: POnigRegexType;  //* escape compile-conflict */
  end;

  POnigRegex  = ^OnigRegex;
  OnigRegex   = POnigRegexType;
  regex_t     = OnigRegexType;

  POnigCompileInfo= ^OnigCompileInfo;
  OnigCompileInfo = record
    num_of_elements: Integer;
    pattern_enc: OnigEncoding;
    target_enc: OnigEncoding;
    syntax: POnigSyntaxType;
    option: OnigOptionType;
    ambig_flag: OnigAmbigType;
  end;

//* Oniguruma Native API */
  Tonig_init                            = function: Integer; cdecl;
  Tonig_error_code_to_str               = function(s: POnigUChar; err_code: Integer; einfo: POnigErrorInfo): Integer; cdecl;
  Tonig_set_warn_func                   = procedure(f: TOnigWarnFunc); cdecl;
  Tonig_set_verb_warn_func              = procedure(f: TOnigWarnFunc); cdecl;
  Tonig_new                             = function(reg: POnigRegex; const pattern, pattern_end: POnigUChar; option: OnigOptionType; enc: OnigEncoding; syntax: POnigSyntaxType; einfo: POnigErrorInfo): Integer; cdecl;
  Tonig_new_deluxe                      = function(reg: POnigRegex; const pattern, pattern_end: POnigUChar; ci: POnigCompileInfo; einfo: POnigErrorInfo): Integer; cdecl;
  Tonig_free                            = procedure(reg: OnigRegex); cdecl;
  Tonig_recompile                       = function(reg: OnigRegex; const pattern, pattern_end: POnigUChar; option: OnigOptionType; enc: OnigEncoding; syntax: POnigSyntaxType; einfo: POnigErrorInfo): Integer; cdecl;
  Tonig_recompile_deluxe                = function(reg: OnigRegex; const pattern, pattern_end: POnigUChar; ci: POnigCompileInfo; einfo: POnigErrorInfo): Integer; cdecl;
  Tonig_search                          = function(reg: OnigRegex; const str, str_end, start, range: POnigUChar; region: POnigRegion; option: OnigOptionType): Integer; cdecl;
  Tonig_match                           = function(reg: OnigRegex; const str, str_end, at: POnigUChar; region: POnigRegion; option: OnigOptionType): Integer; cdecl;
  Tonig_region_new                      = function: POnigRegion; cdecl;
  Tonig_region_init                     = procedure(region: POnigRegion); cdecl;
  Tonig_region_free                     = procedure(region: POnigRegion; free_self: Integer); cdecl;
  Tonig_region_copy                     = procedure(dest, src: POnigRegion); cdecl;
  Tonig_region_clear                    = procedure(region: POnigRegion); cdecl;
  Tonig_region_resize                   = function(region: POnigRegion; n: Integer): Integer; cdecl;
  Tonig_region_set                      = function(region: POnigRegion; at, match_beg, match_end: Integer): Integer; cdecl;
  Tonig_name_to_group_numbers           = function(reg: OnigRegex; const group_name, name_end: POnigUChar; var nums: PInteger): Integer; cdecl;
  Tonig_name_to_backref_number          = function(reg: OnigRegex; const group_name, name_end: POnigUChar; region: POnigRegion): Integer; cdecl;
  Tfunc                                 = function(const group_name, name_end: POnigUChar; ngroup_num: Integer; group_nums: PInteger; reg: OnigRegex; arg: Pointer): Integer; cdecl;
  Tonig_foreach_name                    = function(reg: OnigRegex; f: Tfunc; arg: Pointer): Integer; cdecl;
  Tonig_number_of_names                 = function(reg: OnigRegex): Integer; cdecl;
  Tonig_number_of_captures              = function(reg: OnigRegex): Integer; cdecl;
  Tonig_number_of_capture_histories     = function(reg: OnigRegex): Integer; cdecl;
  Tonig_get_capture_tree                = function(region: POnigRegion): POnigCaptureTreeNode; cdecl;
  Tcallback_func                        = function(group, match_beg, match_end, level, at: Integer; arg: Pointer): Integer; cdecl;
  Tonig_capture_tree_traverse           = function(region: POnigRegion; at: Integer; cf: Tcallback_func; arg: Pointer): Integer; cdecl;
  Tonig_noname_group_capture_is_active  = function(reg: OnigRegex): Integer; cdecl;
  Tonig_get_encoding                    = function(reg: OnigRegex): OnigEncoding; cdecl;
  Tonig_get_options                     = function(reg: OnigRegex): OnigOptionType; cdecl;
  Tonig_get_ambig_flag                  = function(reg: OnigRegex): OnigAmbigType; cdecl;
  Tonig_get_syntax                      = function(reg: OnigRegex): POnigSyntaxType; cdecl;
  Tonig_set_default_syntax              = function(syntax: POnigSyntaxType): Integer; cdecl;
  Tonig_copy_syntax                     = procedure(dest, src: POnigSyntaxType); cdecl;
  Tonig_get_syntax_op                   = function(syntax: POnigSyntaxType): Cardinal; cdecl;
  Tonig_get_syntax_op2                  = function(syntax: POnigSyntaxType): Cardinal; cdecl;
  Tonig_get_syntax_behavior             = function(syntax: POnigSyntaxType): Cardinal; cdecl;
  Tonig_get_syntax_options              = function(syntax: POnigSyntaxType): OnigOptionType; cdecl;
  Tonig_set_syntax_op                   = procedure(syntax: POnigSyntaxType; op: Cardinal); cdecl;
  Tonig_set_syntax_op2                  = procedure(syntax: POnigSyntaxType; op2: Cardinal); cdecl;
  Tonig_set_syntax_behavior             = procedure(syntax: POnigSyntaxType; behavior: Cardinal); cdecl;
  Tonig_set_syntax_options              = procedure(syntax: POnigSyntaxType; options: OnigOptionType); cdecl;
  Tonig_set_meta_char                   = function(enc: OnigEncoding; what: Cardinal; code: OnigCodePoint): Integer; cdecl;
  Tonig_copy_encoding                   = procedure(dest, src: OnigEncoding); cdecl;
  Tonig_get_default_ambig_flag          = function: OnigAmbigType; cdecl;
  Tonig_set_default_ambig_flag          = function(ambig_flag: OnigAmbigType): Integer; cdecl;
  Tonig_get_match_stack_limit_size      = function: Cardinal; cdecl;
  Tonig_set_match_stack_limit_size      = function(size: Cardinal): Integer; cdecl;
  Tonig_end                             = function: Integer; cdecl;
  Tonig_version                         = function: PChar; cdecl;
  Tonig_copyright                       = function: PChar; cdecl;

var
  onig_init:                              Tonig_init;
  onig_error_code_to_str:                 Tonig_error_code_to_str;
  onig_set_warn_func:                     Tonig_set_warn_func;
  onig_set_verb_warn_func:                Tonig_set_verb_warn_func;
  onig_new:                               Tonig_new;
  onig_new_deluxe:                        Tonig_new_deluxe;
  onig_free:                              Tonig_free;
  onig_recompile:                         Tonig_recompile;
  onig_recompile_deluxe:                  Tonig_recompile_deluxe;
  onig_search:                            Tonig_search;
  onig_match:                             Tonig_match;
  onig_region_new:                        Tonig_region_new;
  onig_region_init:                       Tonig_region_init;
  onig_region_free:                       Tonig_region_free;
  onig_region_copy:                       Tonig_region_copy;
  onig_region_clear:                      Tonig_region_clear;
  onig_region_resize:                     Tonig_region_resize;
  onig_region_set:                        Tonig_region_set;
  onig_name_to_group_numbers:             Tonig_name_to_group_numbers;
  onig_name_to_backref_number:            Tonig_name_to_backref_number;
  onig_foreach_name:                      Tonig_foreach_name;
  onig_number_of_names:                   Tonig_number_of_names;
  onig_number_of_captures:                Tonig_number_of_captures;
  onig_number_of_capture_histories:       Tonig_number_of_capture_histories;
  onig_get_capture_tree:                  Tonig_get_capture_tree;
  onig_capture_tree_traverse:             Tonig_capture_tree_traverse;
  onig_noname_group_capture_is_active:    Tonig_noname_group_capture_is_active;
  onig_get_encoding:                      Tonig_get_encoding;
  onig_get_options:                       Tonig_get_options;
  onig_get_ambig_flag:                    Tonig_get_ambig_flag;
  onig_get_syntax:                        Tonig_get_syntax;
  onig_set_default_syntax:                Tonig_set_default_syntax;
  onig_copy_syntax:                       Tonig_copy_syntax;
  onig_get_syntax_op:                     Tonig_get_syntax_op;
  onig_get_syntax_op2:                    Tonig_get_syntax_op2;
  onig_get_syntax_behavior:               Tonig_get_syntax_behavior;
  onig_get_syntax_options:                Tonig_get_syntax_options;
  onig_set_syntax_op:                     Tonig_set_syntax_op;
  onig_set_syntax_op2:                    Tonig_set_syntax_op2;
  onig_set_syntax_behavior:               Tonig_set_syntax_behavior;
  onig_set_syntax_options:                Tonig_set_syntax_options;
  onig_set_meta_char:                     Tonig_set_meta_char;
  onig_copy_encoding:                     Tonig_copy_encoding;
  onig_get_default_ambig_flag:            Tonig_get_default_ambig_flag;
  onig_set_default_ambig_flag:            Tonig_set_default_ambig_flag;
  onig_get_match_stack_limit_size:        Tonig_get_match_stack_limit_size;
  onig_set_match_stack_limit_size:        Tonig_set_match_stack_limit_size;
  onig_end:                               Tonig_end;
  onig_version:                           Tonig_version;
  onig_copyright:                         Tonig_copyright;


implementation


function ONIG_IS_PATTERN_ERROR(ecode: Integer): Boolean;
begin
  Result := ((ecode <= -100) and (ecode > -1000));
end;

end.
