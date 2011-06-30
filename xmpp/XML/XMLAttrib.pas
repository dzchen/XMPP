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
unit XMLAttrib;


interface

uses
    XMLNode;

type
  TXMLAttrib = class(TXMLNode)
  private
    fData: Utf8String;
    function Get_Data: Utf8String; safecall;
    procedure Set_Data(const Value: Utf8String); safecall;
  protected
  public
    constructor Create; override;
    destructor Destroy; override;

    function XML: Utf8String; override;
    property Data: Utf8String read Get_Data write Set_Data;
  end;


implementation

uses

    SysUtils;

{---------------------------------------}
constructor TXMLAttrib.Create;
begin
    inherited;
    
    Name := '';
    NodeType := xml_Attribute;
    fData := '';
end;

{---------------------------------------}
destructor TXMLAttrib.Destroy;
begin
    inherited Destroy;
end;

{---------------------------------------}
function TXMLAttrib.Get_Data: Utf8String;
begin
    //Result := XML_UnescapeChars(fData);
end;

{---------------------------------------}
procedure TXMLAttrib.Set_Data(const Value: Utf8String);
begin
    //fData := TrimQuotes(Value);
end;

{---------------------------------------}
function TXMLAttrib.XML: Utf8String;
begin
    // Return the XML Utf8String
    //Result := Name + '="' + XML_EscapeChars(fData) + '"';
end;


end.
