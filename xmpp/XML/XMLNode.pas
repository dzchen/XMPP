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
unit XMLNode;


interface



type
  XMLNodeType = (xml_Node, xml_Tag, xml_Attribute, xml_CDATA);
  TXMLNode = class
  private
    fName: Utf8String;
    ftype: XMLNodeType;

    function Get_Name: Utf8String;
    function Get_NodeType: XMLNodeType;

    procedure Set_Name(const Value: Utf8String);
    procedure Set_NodeType(Value: XMLNodeType);
  protected
    { Protected declarations }
  public
    constructor Create; virtual;

    property Name: Utf8String read Get_Name write Set_Name;
    property NodeType: XMLNodeType read Get_NodeType write Set_NodeType;
    function IsTag: boolean;
    function XML: Utf8String; virtual;
  end;



{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
uses
    SysUtils;

{---------------------------------------}
constructor TXMLNode.Create;
begin
    inherited;

    fName := '';
    ftype := xml_node;
end;

{---------------------------------------}
function TXMLNode.Get_Name: Utf8String;
begin
    Result := fName;
end;

{---------------------------------------}
procedure TXMLNode.Set_Name(const Value: Utf8String);
begin
    fName := Value;
end;

{---------------------------------------}
function TXMLNode.IsTag: Boolean;
begin
    // Is this a tag or not??
    if NodeType = xml_Tag then
        Result := true
    else
        Result := false;
end;

{---------------------------------------}
function TXMLNode.XML: Utf8String;
begin
    // Abstract method, should be overridden in
    // descendant classes.
end;

{---------------------------------------}
function TXMLNode.Get_NodeType: XMLNodeType;
begin
    Result := ftype;
end;

{---------------------------------------}
procedure TXMLNode.Set_NodeType(Value: XMLNodeType);
begin
    ftype := Value;
end;

end.
