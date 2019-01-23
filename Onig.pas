// Onig.pas - 2006.04.10
unit Onig;

interface

uses Oniguruma, Windows;

function OnigLoadLibrary: Boolean;
procedure OnigFreeLibrary;

implementation

var
  FHandle: THandle;

function OnigLoadLibrary: Boolean;
begin
  FHandle := LoadLibrary('onig.dll');
  Result := (FHandle <> 0);
  if Result then
  begin
    // ONIG_ENCODING
    @ONIG_ENCODING_ASCII                  := GetProcAddress(FHandle, 'OnigEncodingASCII');
    @ONIG_ENCODING_ISO_8859_1             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_1');
    @ONIG_ENCODING_ISO_8859_2             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_2');
    @ONIG_ENCODING_ISO_8859_3             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_3');
    @ONIG_ENCODING_ISO_8859_4             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_4');
    @ONIG_ENCODING_ISO_8859_5             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_5');
    @ONIG_ENCODING_ISO_8859_6             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_6');
    @ONIG_ENCODING_ISO_8859_7             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_7');
    @ONIG_ENCODING_ISO_8859_8             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_8');
    @ONIG_ENCODING_ISO_8859_9             := GetProcAddress(FHandle, 'OnigEncodingISO_8859_9');
    @ONIG_ENCODING_ISO_8859_10            := GetProcAddress(FHandle, 'OnigEncodingISO_8859_10');
    @ONIG_ENCODING_ISO_8859_11            := GetProcAddress(FHandle, 'OnigEncodingISO_8859_11');
    @ONIG_ENCODING_ISO_8859_13            := GetProcAddress(FHandle, 'OnigEncodingISO_8859_13');
    @ONIG_ENCODING_ISO_8859_14            := GetProcAddress(FHandle, 'OnigEncodingISO_8859_14');
    @ONIG_ENCODING_ISO_8859_15            := GetProcAddress(FHandle, 'OnigEncodingISO_8859_15');
    @ONIG_ENCODING_ISO_8859_16            := GetProcAddress(FHandle, 'OnigEncodingISO_8859_16');
    @ONIG_ENCODING_UTF8                   := GetProcAddress(FHandle, 'OnigEncodingUTF8');
    @ONIG_ENCODING_UTF16_BE               := GetProcAddress(FHandle, 'OnigEncodingUTF16_BE');
    @ONIG_ENCODING_UTF16_LE               := GetProcAddress(FHandle, 'OnigEncodingUTF16_LE');
    @ONIG_ENCODING_UTF32_BE               := GetProcAddress(FHandle, 'OnigEncodingUTF32_BE');
    @ONIG_ENCODING_UTF32_LE               := GetProcAddress(FHandle, 'OnigEncodingUTF32_LE');
    @ONIG_ENCODING_EUC_JP                 := GetProcAddress(FHandle, 'OnigEncodingEUC_JP');
    @ONIG_ENCODING_EUC_TW                 := GetProcAddress(FHandle, 'OnigEncodingEUC_TW');
    @ONIG_ENCODING_EUC_KR                 := GetProcAddress(FHandle, 'OnigEncodingEUC_KR');
    @ONIG_ENCODING_EUC_CN                 := GetProcAddress(FHandle, 'OnigEncodingEUC_CN');
    @ONIG_ENCODING_SJIS                   := GetProcAddress(FHandle, 'OnigEncodingSJIS');
    @ONIG_ENCODING_KOI8                   := GetProcAddress(FHandle, 'OnigEncodingKOI8');
    @ONIG_ENCODING_KOI8_R                 := GetProcAddress(FHandle, 'OnigEncodingKOI8_R');
    @ONIG_ENCODING_BIG5                   := GetProcAddress(FHandle, 'OnigEncodingBIG5');
    @ONIG_ENCODING_GB18030                := GetProcAddress(FHandle, 'OnigEncodingGB18030');

    // Oniguruma Encoding API
    @onigenc_init                         := GetProcAddress(FHandle, 'onigenc_init');
    @onigenc_set_default_encoding         := GetProcAddress(FHandle, 'onigenc_set_default_encoding');
    @onigenc_get_default_encoding         := GetProcAddress(FHandle, 'onigenc_get_default_encoding');
    @onigenc_set_default_caseconv_table   := GetProcAddress(FHandle, 'onigenc_set_default_caseconv_table');
    @onigenc_get_right_adjust_char_head_with_prev
                                          := GetProcAddress(FHandle, 'onigenc_get_right_adjust_char_head_with_prev');
    @onigenc_get_prev_char_head           := GetProcAddress(FHandle, 'onigenc_get_prev_char_head');
    @onigenc_get_left_adjust_char_head    := GetProcAddress(FHandle, 'onigenc_get_left_adjust_char_head');
    @onigenc_get_right_adjust_char_head   := GetProcAddress(FHandle, 'onigenc_get_right_adjust_char_head');
    @onigenc_strlen                       := GetProcAddress(FHandle, 'onigenc_strlen');
    @onigenc_strlen_null                  := GetProcAddress(FHandle, 'onigenc_strlen_null');
    @onigenc_str_bytelen_null             := GetProcAddress(FHandle, 'onigenc_str_bytelen_null');

    // ONIG_SYNTAX
    @ONIG_SYNTAX_ASIS                     := GetProcAddress(FHandle, 'OnigSyntaxASIS');
    @ONIG_SYNTAX_POSIX_BASIC              := GetProcAddress(FHandle, 'OnigSyntaxPosixBasic');
    @ONIG_SYNTAX_POSIX_EXTENDED           := GetProcAddress(FHandle, 'OnigSyntaxPosixExtended');
    @ONIG_SYNTAX_EMACS                    := GetProcAddress(FHandle, 'OnigSyntaxEmacs');
    @ONIG_SYNTAX_GREP                     := GetProcAddress(FHandle, 'OnigSyntaxGrep');
    @ONIG_SYNTAX_GNU_REGEX                := GetProcAddress(FHandle, 'OnigSyntaxGnuRegex');
    @ONIG_SYNTAX_JAVA                     := GetProcAddress(FHandle, 'OnigSyntaxJava');
    @ONIG_SYNTAX_PERL                     := GetProcAddress(FHandle, 'OnigSyntaxPerl');
    @ONIG_SYNTAX_PERL_NG                  := GetProcAddress(FHandle, 'OnigSyntaxPerl_NG');
    @ONIG_SYNTAX_RUBY                     := GetProcAddress(FHandle, 'OnigSyntaxRuby');
    @ONIG_SYNTAX_DEFAULT                  := GetProcAddress(FHandle, 'OnigDefaultSyntax');

    // Oniguruma Native API
    @onig_init                            := GetProcAddress(FHandle, 'onig_init');
    @onig_error_code_to_str               := GetProcAddress(FHandle, 'onig_error_code_to_str');
    @onig_set_warn_func                   := GetProcAddress(FHandle, 'onig_set_warn_func');
    @onig_set_verb_warn_func              := GetProcAddress(FHandle, 'onig_set_verb_warn_func');
    @onig_new                             := GetProcAddress(FHandle, 'onig_new');
    @onig_new_deluxe                      := GetProcAddress(FHandle, 'onig_new_deluxe');
    @onig_free                            := GetProcAddress(FHandle, 'onig_free');
    @onig_recompile                       := GetProcAddress(FHandle, 'onig_recompile');
    @onig_recompile_deluxe                := GetProcAddress(FHandle, 'onig_recompile_deluxe');
    @onig_search                          := GetProcAddress(FHandle, 'onig_search');
    @onig_match                           := GetProcAddress(FHandle, 'onig_match');
    @onig_region_new                      := GetProcAddress(FHandle, 'onig_region_new');
    @onig_region_init                     := GetProcAddress(FHandle, 'onig_region_init');
    @onig_region_free                     := GetProcAddress(FHandle, 'onig_region_free');
    @onig_region_copy                     := GetProcAddress(FHandle, 'onig_region_copy');
    @onig_region_clear                    := GetProcAddress(FHandle, 'onig_region_clear');
    @onig_region_resize                   := GetProcAddress(FHandle, 'onig_region_resize');
    @onig_region_set                      := GetProcAddress(FHandle, 'onig_region_set');
    @onig_name_to_group_numbers           := GetProcAddress(FHandle, 'onig_name_to_group_numbers');
    @onig_name_to_backref_number          := GetProcAddress(FHandle, 'onig_name_to_backref_number');
    @onig_foreach_name                    := GetProcAddress(FHandle, 'onig_foreach_name');
    @onig_number_of_names                 := GetProcAddress(FHandle, 'onig_number_of_names');
    @onig_number_of_captures              := GetProcAddress(FHandle, 'onig_number_of_captures');
    @onig_number_of_capture_histories     := GetProcAddress(FHandle, 'onig_number_of_capture_histories');
    @onig_get_capture_tree                := GetProcAddress(FHandle, 'onig_get_capture_tree');
    @onig_capture_tree_traverse           := GetProcAddress(FHandle, 'onig_capture_tree_traverse');
    @onig_noname_group_capture_is_active  := GetProcAddress(FHandle, 'onig_noname_group_capture_is_active');
    @onig_get_encoding                    := GetProcAddress(FHandle, 'onig_get_encoding');
    @onig_get_options                     := GetProcAddress(FHandle, 'onig_get_options');
    @onig_get_ambig_flag                  := GetProcAddress(FHandle, 'onig_get_ambig_flag');
    @onig_get_syntax                      := GetProcAddress(FHandle, 'onig_get_syntax');
    @onig_set_default_syntax              := GetProcAddress(FHandle, 'onig_set_default_syntax');
    @onig_copy_syntax                     := GetProcAddress(FHandle, 'onig_copy_syntax');
    @onig_get_syntax_op                   := GetProcAddress(FHandle, 'onig_get_syntax_op');
    @onig_get_syntax_op2                  := GetProcAddress(FHandle, 'onig_get_syntax_op2');
    @onig_get_syntax_behavior             := GetProcAddress(FHandle, 'onig_get_syntax_behavior');
    @onig_get_syntax_options              := GetProcAddress(FHandle, 'onig_get_syntax_options');
    @onig_set_syntax_op                   := GetProcAddress(FHandle, 'onig_set_syntax_op');
    @onig_set_syntax_op2                  := GetProcAddress(FHandle, 'onig_set_syntax_op2');
    @onig_set_syntax_behavior             := GetProcAddress(FHandle, 'onig_set_syntax_behavior');
    @onig_set_syntax_options              := GetProcAddress(FHandle, 'onig_set_syntax_options');
    @onig_set_meta_char                   := GetProcAddress(FHandle, 'onig_set_meta_char');
    @onig_copy_encoding                   := GetProcAddress(FHandle, 'onig_copy_encoding');
    @onig_get_default_ambig_flag          := GetProcAddress(FHandle, 'onig_get_default_ambig_flag');
    @onig_set_default_ambig_flag          := GetProcAddress(FHandle, 'onig_set_default_ambig_flag');
    @onig_get_match_stack_limit_size      := GetProcAddress(FHandle, 'onig_get_match_stack_limit_size');
    @onig_set_match_stack_limit_size      := GetProcAddress(FHandle, 'onig_set_match_stack_limit_size');
    @onig_end                             := GetProcAddress(FHandle, 'onig_end');
    @onig_version                         := GetProcAddress(FHandle, 'onig_version');
    @onig_copyright                       := GetProcAddress(FHandle, 'onig_copyright');
  end;
end;

procedure OnigFreeLibrary;
begin
  if (FHandle <> 0) then
    FreeLibrary(FHandle);
  FHandle := 0;
end;

end.
