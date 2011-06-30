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
unit XMLParser;


interface

uses
     XMLTag,
    XMLUtils, NativeXml, SysUtils, Classes;

type
    TXMLTagParser = class
    private
        _parser: tnativexml;
        _dom_list: TList;
        function processTag(curtag: TXMLTag): TXMLTag;

    public
        constructor Create();
        destructor Destroy; override;

        procedure ParseString(buff: Utf8String; stream_tag: Utf8String = '');
        procedure ParseFile(filename: String);

        // from the current exe
        procedure ParseResource(const resName: string); overload;
        // from the given exe/dll
        procedure ParseResource(const resFile: string; const resName: string); overload;
        procedure ParseResource(const instance: cardinal; const resName: string); overload;

        procedure Clear();
        function Count: integer;
        function popTag: TXMLTag;
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

uses Windows;

{---------------------------------------}
constructor TXMLTagParser.Create();
begin
    inherited;


    _dom_list := TList.Create;
end;

{---------------------------------------}
destructor TXMLTagParser.Destroy;
begin
    _parser.Free;
    _dom_list.Free;
    inherited Destroy;
end;

{---------------------------------------}
function TXMLTagParser.Count: integer;
begin
    Result := _dom_list.Count;
end;

function TXMLTagParser.popTag: TXMLTag;
begin
    if _dom_list.Count > 0 then begin
        Result := TXMLTag(_dom_list[0]);
        _dom_list.Delete(0);
    end
    else
        Result := nil;
end;

{---------------------------------------}
procedure TXMLTagParser.ParseFile(filename: String);
begin
    // Open the file, suck it into a stringlist
    // and send it off to the parser.

    if (not FileExists(filename)) then exit;



    //Self.ParseString(s, '');

end;

{---------------------------------------}
procedure TXMLTagParser.ParseResource(const instance: cardinal; const resName: string);
var
    res: TResourceStream;
    sl: TStringList;
begin
    res := TResourceStream.Create(instance, ResName, 'XML');
    sl := TStringList.Create();
    sl.LoadFromStream(res);
    res.Free();
    ParseString(sl.Text, '');
    sl.Free();
end;

{---------------------------------------}
procedure TXMLTagParser.ParseResource(const resName: string);
begin
    ParseResource(HInstance, resName);
end;

{---------------------------------------}
procedure TXMLTagParser.ParseResource(const resFile: string; const resName: string);
var
    handle: cardinal;
begin
    handle := LoadLibrary(pchar(resFile));
    ParseResource(handle, resName);
end;

{---------------------------------------}
procedure TXMLTagParser.ParseString(buff, stream_tag: Utf8String);
var
    i: longint;
     tmps: Utf8String;

    curtag: TXMLTag;
begin
    // copy the buffer into a PChar
    //cp_buff := buff;

    // StrPCopy(pbuff, cp_buff);

    // parse the buffer
    _parser.LoadFromBuffer(buff);
    _parser.StartScan;
    _parser.Normalize := false;
    curtag := nil;

    // Parse until we can't parse anymore
    while _parser.Scan do begin
        case _parser.CurPartType of
        ptEmptyTag, ptStartTag: begin
            // normal tags
            if (_parser.CurFinal[0] <> '>') then begin
                // we don't have a full tag..
                tmps := String(_parser.CurStart);
            end
            else begin
                // create or add the tag element.
                if curtag = nil then
                    curtag := TXMLTag.Create(Trim(_parser.CurName))
                else
                    curtag := curtag.AddTag(Trim(_parser.CurName));

                // add all the attributes to it..
                for i := 0 to _parser.CurAttr.Count - 1 do
                    curtag.setAttribute(_parser.CurAttr.Name(i), _parser.CurAttr.Value(i));

                // If this is an empty tag <foo bar="item"/>, dispatch send
                if _parser.CurPartType = ptEmptyTag then
                    curtag := processTag(curtag);

                // automatically handle root element tags
                // since they will never be closed
                if _parser.CurName = stream_tag then
                    curtag := processTag(curtag);

            end;
        end;
        ptContent, ptCDATA: begin
            // cdata for the current tag
            if curtag <> nil then begin
                tmps := Trim(_parser.CurContent);
                if tmps <> '' then
                    curtag.AddCData(_parser.CurContent);
            end;
        end;
        ptEndTag: begin
            // we have an end tag, process the end tag
            if curtag <> nil then begin
                curtag := processTag(curtag);
            end;
        end;
    end;

    end;
    // StrDispose(pbuff);
    //StrDisposeW(pbuff);
end;

{---------------------------------------}
procedure TXmlTagParser.Clear();
begin
    _dom_list.Clear();
end;

{---------------------------------------}
function TXMLTagParser.processTag(curtag: TXMLTag): TXMLTag;
begin
    if curtag = nil then
        Result := nil

    else if (curtag.pTag = nil) then begin
        // end of a fragment.. add it to the list
        _dom_list.Add(curtag);
        Result := nil;
    end

    else begin
        Result := curtag.pTag;
    end;
end;

end.
