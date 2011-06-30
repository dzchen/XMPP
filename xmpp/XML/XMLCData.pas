{
    Copyright 2001-2008, Estate of Peter Millard
	
	This file is part of Exodus.
	
	Exodus is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
	
	Exodus is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with Exodus; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit XMLCData;


interface

uses
    XMLNode;

type
  TXMLCData = class(TXMLNode)
  private
    fData: Utf8String;
  protected
    { Protected declarations }
    function Get_Text: Utf8String;
    procedure Set_Text(const Value: Utf8String);
  public
    constructor Create; overload; override;
    constructor Create(content: Utf8String); reintroduce; overload;
    destructor Destroy; override;

    // pgm_virt
    function XML: Utf8String; override;
    property Data: Utf8String read Get_Text write Set_Text;
  end;

  TXML_CData = TXMLCData;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

uses


    SysUtils;

{---------------------------------------}
constructor TXMLCData.Create;
begin
    inherited;

    Name := '#TEXT';
    NodeType := xml_CDATA;
    fData := '';
end;

{---------------------------------------}
constructor TXMLCData.Create(content: Utf8String);
begin
    Create();
    Set_Text(content);
end;

{---------------------------------------}
destructor TXMLCData.Destroy;
begin
    fData := '';

    inherited Destroy;
end;

{---------------------------------------}
function TXMLCData.Get_Text: Utf8String;
begin
    //Result := XML_UnescapeChars(fData);
    Result := fData;
end;

{---------------------------------------}
procedure TXMLCData.Set_Text(const Value: Utf8String);
var
    p1: integer;
    tmps: Utf8String;
begin
    // set text into the data prop..
    // deal w/ <![CDATA[   ---   ]]> here

    // pgm 2/28/01 - DON'T TRIM THIS!!
    // tmps := Trim(Value);
    tmps := Value;
    p1 := Pos('<![CDATA[', Uppercase(tmps));
    if p1 > 0 then begin
        // we have cdata... remove the CDATA tags
        Delete(tmps, p1, 9);
        p1 := Pos(']]>', tmps);
        if p1 > 0 then
            Delete(tmps, p1, 3);
        Name := '#CDATA';
    end
    else
        tmps := tmps;
    fData := tmps;
end;

{---------------------------------------}
function TXMLCData.XML: Utf8String;
var
    tmps: Utf8String;
begin
    // Return the XML Utf8String
    // Build and return the element xml text..
    {if Name = '#CDATA' then
        tmps := '<![CDATA[ ' + fData + ' ]]>'
    else
        tmps := XML_EscapeChars(fData);   }
    Result := tmps;
end;

end.
