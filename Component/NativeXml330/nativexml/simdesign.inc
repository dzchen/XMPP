{ simdesign.inc

  include file for many simdesign projects
  default path: \simlib\general

  Author: Nils Haeck M.Sc.
  Copyright (c) 2007 - 2011 Simdesign B.V.

}
// Delphi and FPC versions

// Freepascal
{$ifdef FPC}
  {$MODE DELPHI}
  {$define D7UP}
{$endif FPC}
// Delphi 5
{$ifdef VER130}
  {$define D5UP}
{$endif}
//Delphi 6
{$ifdef VER140}
  {$define D5UP}
{$endif}
//Delphi 7
{$ifdef VER150}
  {$define D7UP}
{$endif}
//Delphi 8
{$ifdef VER160}
  {$define D7UP}
{$endif}
// Delphi 2005
{$ifdef VER170}
  {$define D7UP}
{$endif}
// Delphi 2006
{$ifdef VER180}
  {$define D7UP}
{$endif}
// Delphi 2007 Rad studio
{$ifdef VER185}
  {$define D7UP}
{$endif}
// Delphi 2007 - NET
{$ifdef VER190}
  {$define D7UP}
{$endif}
// Delphi 2009
{$ifdef VER200}
  {$define D7UP}
  {$define D12UP}
{$endif}
// Delphi 2010
{$ifdef VER210}
  {$define D7UP}
  {$define D12UP}
{$endif}
// Delphi XE
{$ifdef VER220}
  {$define D7UP}
  {$define D12UP}
  {$define D15UP}
{$endif}

{ Remove the dot to use the LittleCMS library to apply ICC colour profiles to
  your bitmaps. Please note the license details. The LittleCMS API is located
  in the extlib/color/lcms subfolder. For an example on use, see procedure JpegApplyICC.
  More info on LittleCMS: http://www.littlecms.com
  When using LittleCMS, make sure that a copy of lcms.dll is located
  in your application's exe path or in another accessible global location.}
{.$define useLittleCMS}

