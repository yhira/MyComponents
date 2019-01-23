(*********************************************************************

  heverdef.inc

  start  2001/07/16
  update 2006/04/29

  --------------------------------------------------------------------
  ���̃C���N���[�h�t�@�C���� SynEdit http://synedit.sourceforge.net/
  ���Q�l�ɂ����Ē����܂����B

  Delphi1        VER80
  Delphi2        VER90
  C++Builder1    VER93
  Delphi3        VER100
  C++Builder3    VER110
  Delphi4        VER120
  C++Builder4    VER125
  Delphi5        VER130
  C++Builder5    VER130
  Delphi6        VER140
  Delphi7        VER150
  Delphi8        VER160
  Delphi2005     VER170
  BDS2006        VER180
  
  �ȏ�̃o�[�W�����ɑΉ����Ă��܂��B�܂��ABDS2006 �ȍ~�̃o�[�W�����ɂ�
  �Ή��o����悤�ɁA���L COMP1_UP ������`�̏ꍇ�� BDS2006 �ȍ~�̃o�[
  �W�����ł���Ƃ������ʏ������s���Ă��܂��B
  
  --------------------------------------------------------------------
  ��`���������V���{��

  �V���{��       �Ӗ�
  COMP1          Delphi1
  COMP1_UP       Delphi1 �ȏ�
  COMP2          Delphi2, C++Builder1
  COMP2_UP       Delphi2 �ȏ�, C++Builder1 �ȏ�
  COMP3          Delphi3, C++Builder3
  COMP3_UP       Delphi3 �ȏ�, C++Builder3 �ȏ�
  COMP4          Delphi4, C++Builder4
  COMP4_UP       Delphi4 �ȏ�, C++Builder4 �ȏ�
  COMP5          Delphi5, C++Builder5
  COMP5_UP       Delphi5 �ȏ�, C++Builder5 �ȏ�
  COMP6          Delphi6
  COMP6_UP       Delphi6 �ȏ�
  COMP7          Delphi7
  COMP7_UP       Delphi7 �ȏ�
  COMP8          Delphi8
  COMP8_UP       Delphi8 �ȏ�
  COMP9          Delphi2005
  COMP9_UP       Delphi2005 �ȏ�
  COMP10         BDS2006
  COMP10_UP      BDS2006 �ȏ�
  DELPHI1        Delphi1
  DELPHI1_UP     Delphi1 �ȏ�
  DELPHI2        Delphi2
  DELPHI2_UP     Delphi2 �ȏ�
  DELPHI3        Delphi3
  DELPHI3_UP     Delphi3 �ȏ�
  DELPHI4        Delphi4
  DELPHI4_UP     Delphi4 �ȏ�
  DELPHI5        Delphi5
  DELPHI5_UP     Delphi5 �ȏ�
  DELPHI6        Delphi6
  DELPHI6_UP     Delphi6 �ȏ�
  DELPHI7        Delphi7
  DELPHI7_UP     Delphi7 �ȏ�
  DELPHI8        Delphi8
  DELPHI8_UP     Delphi8 �ȏ�
  DELPHI2005     Delphi2005
  DELPHI2005_UP  Delphi2005 �ȏ�
  BDS2006        BDS2006
  BDS2006_UP     BDS2006 �ȏ�
  BCB1           C++Builder1
  BCB1_UP        C++Builder1 �ȏ�
  BCB3           C++Builder3
  BCB3_UP        C++Builder3 �ȏ�
  BCB4           C++Builder4
  BCB4_UP        C++Builder4 �ȏ�
  BCB5           C++Builder5
  BCB5_UP        C++Builder5 �ȏ�

  --------------------------------------------------------------------
  C++Builder 3 �ȍ~�̏ꍇ�A$ObjExportAll On ���w�肳��܂�

  --------------------------------------------------------------------
  Delphi 4, C++Builder 3 �ȍ~�ł́ATList.Clear �� virtual �ɂȂ��Ă���
  ���ƂɑΉ����邽�߂� TLIST_CLEAR_VIRTUAL ����`����܂�

  --------------------------------------------------------------------
  �܂��A�ȉ��̃R���p�C���w�߂��w�肳��Ă��܂�

  V+  VAR ������̌�������
  B-  ���S�Ș_���]��
  X+  �g���\��
  T-  �^�t�� @ ���Z�q
  P+  �I�[�v���p�����[�^
  H+  ������������g��
  J+  �^�t���萔�ւ̑��

*********************************************************************)

// Borland Developer Studio 2006
{$IFDEF VER180}
  {$DEFINE COMP10}
  {$DEFINE BDS2006}
{$ENDIF}

// Delphi 2005
{$IFDEF VER170}
  {$DEFINE COMP9}
  {$DEFINE DELPHI2005}
{$ENDIF}

// Delphi 8
{$IFDEF VER160}
  {$DEFINE COMP8}
  {$DEFINE DELPHI8}
{$ENDIF}

// Delphi 7
{$IFDEF VER150}
  {$DEFINE COMP7}
  {$DEFINE DELPHI7}
{$ENDIF}

// Delphi 6
{$IFDEF VER140}
  {$DEFINE COMP6}
  {$DEFINE DELPHI6}
{$ENDIF}

// Delphi 5, C++Builder 5
{$IFDEF VER130}
  {$DEFINE COMP5}
  {$DEFINE BCB5}
  {$DEFINE DELPHI5}
{$ENDIF}

// C++Builder 4
{$IFDEF VER125}
  {$DEFINE COMP4}
  {$DEFINE BCB4}
{$ENDIF}

// Delphi 4
{$IFDEF VER120}
  {$DEFINE COMP4}
  {$DEFINE DELPHI4}
{$ENDIF}

// C++Builder 3
{$IFDEF VER110}
  {$DEFINE COMP3}
  {$DEFINE BCB3}
{$ENDIF}

// Delphi 3
{$IFDEF VER100}
  {$DEFINE COMP3}
  {$DEFINE DELPHI3}
{$ENDIF}

// C++Builder 1
{$IFDEF VER93}
  {$DEFINE COMP2}
  {$DEFINE BCB1}
{$ENDIF}

// Delphi 2
{$IFDEF VER90}
  {$DEFINE COMP2}
  {$DEFINE DELPHI2}
{$ENDIF}

// Delphi 1
{$IFDEF VER80}
  {$DEFINE COMP1}
  {$DEFINE DELPHI1}
{$ENDIF}

// COMPx_UP
{$IFDEF COMP1}
  {$DEFINE COMP1_UP}
{$ENDIF}

{$IFDEF COMP2}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
{$ENDIF}

{$IFDEF COMP3}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
{$ENDIF}

{$IFDEF COMP4}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
{$ENDIF}

{$IFDEF COMP5}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
{$ENDIF}

{$IFDEF COMP6}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
{$ENDIF}

{$IFDEF COMP7}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
{$ENDIF}

{$IFDEF COMP8}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP8_UP}
{$ENDIF}

{$IFDEF COMP9}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP9_UP}
{$ENDIF}

{$IFDEF COMP10}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP9_UP}
  {$DEFINE COMP10_UP}
{$ENDIF}

// DELPHIx_UP
{$IFDEF DELPHI1}
  {$DEFINE DELPHI1_UP}
{$ENDIF}

{$IFDEF DELPHI2}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
{$ENDIF}

{$IFDEF DELPHI3}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
{$ENDIF}

{$IFDEF DELPHI4}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
{$ENDIF}

{$IFDEF DELPHI5}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
{$ENDIF}

{$IFDEF DELPHI6}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
{$ENDIF}

{$IFDEF DELPHI7}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
{$ENDIF}

{$IFDEF DELPHI8}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
{$ENDIF}

{$IFDEF DELPHI2005}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI2005_UP}
{$ENDIF}

{$IFDEF BDS2006}
  {$DEFINE DELPHI1_UP}
  {$DEFINE DELPHI2_UP}
  {$DEFINE DELPHI3_UP}
  {$DEFINE DELPHI4_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI2005_UP}
  {$DEFINE BDS2006_UP}
{$ENDIF}

// BCBx_UP
{$IFDEF BCB1}
  {$DEFINE BCB1_UP}
{$ENDIF}

{$IFDEF BCB3}
  {$DEFINE BCB1_UP}
  {$DEFINE BCB3_UP}
{$ENDIF}

{$IFDEF BCB4}
  {$DEFINE BCB1_UP}
  {$DEFINE BCB3_UP}
  {$DEFINE BCB4_UP}
{$ENDIF}

{$IFDEF BCB5}
  {$DEFINE BCB1_UP}
  {$DEFINE BCB3_UP}
  {$DEFINE BCB4_UP}
  {$DEFINE BCB5_UP}
{$ENDIF}

{$IFDEF BCB3_UP}
  {$ObjExportAll On}
  {$DEFINE TLIST_CLEAR_VIRTUAL}
{$ENDIF}

{$IFDEF DELPHI4_UP}
  {$DEFINE TLIST_CLEAR_VIRTUAL}
{$ENDIF}

{$IFNDEF COMP1_UP}
  {$DEFINE COMP1_UP}
  {$DEFINE COMP2_UP}
  {$DEFINE COMP3_UP}
  {$DEFINE COMP4_UP}
  {$DEFINE COMP5_UP}
  {$DEFINE COMP6_UP}
  {$DEFINE COMP7_UP}
  {$DEFINE COMP8_UP}
  {$DEFINE COMP9_UP}
  {$DEFINE COMP10_UP}
  {$DEFINE TLIST_CLEAR_VIRTUAL}
{$ENDIF}

// �R���p�C���w��
{$V+,B-,X+,T-,P+,H+,J+}
