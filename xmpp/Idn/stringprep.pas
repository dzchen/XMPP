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
unit stringprep;


interface

// Jabber idn stuff
function jabber_nodeprep(input: PChar; output: PChar; buf_sz: integer): integer; cdecl; external 'libidn.dll' name 'jabber_nodeprep';
function jabber_nameprep(input: PChar; output: PChar; buf_sz: integer): integer; cdecl; external 'libidn.dll' name 'jabber_nameprep';
function jabber_resourceprep(input: PChar; output: PChar; buf_sz: integer): integer; cdecl; external 'libidn.dll' name 'jabber_resourceprep';

// Our stuff
function xmpp_nodeprep(input: string): string;
function xmpp_nameprep(input: string): string;
function xmpp_resourceprep(input: string): string;
function jabber_nameprep_variablelen(str: string): string;

implementation
uses
    SysUtils;

function xmpp_nodeprep(input: string): string;
var
    uin: String;
    uout: array[0..1024] of Char;
begin
    Result := '';
    try
        uin := UTF8Encode(input);
        if (jabber_nodeprep(PChar(uin), @uout, 1024) = 0) then
            Result := UTF8Decode(uout);
    except
    end;
end;

function xmpp_nameprep(input: string): string;
var
    uin: String;
    uout: array[0..1024] of Char;
begin
    Result := '';
    try
        uin := UTF8Encode(input);
        if (jabber_nameprep(PChar(uin), @uout, 1024) = 0) then
            Result := UTF8Decode(uout);
    except
    end;
end;

function xmpp_resourceprep(input: string): string;
var
    uin: String;
    uout: array[0..1024] of Char;
begin
    Result := '';
    try
        uin := UTF8Encode(input);
        if (jabber_resourceprep(PChar(uin), @uout, 1024) = 0) then
            Result := UTF8Decode(uout);
    except
    end;
end;

function jabber_nameprep_variablelen(str: string): string;
var
    uin: String;
    uout: string;
    len: integer;
begin
    Result := '';
    try
        uin := UTF8Encode(str);
        len := Length(uin) * 4;  // Set buffer to 4 * the length.  UTF8 is only going to change 1->4 max.
        SetLength(uout, len);
        if ((len > 0) and
            (jabber_nameprep(PChar(uin), PChar(uout), len) = 0)) then
        begin
            uout := Trim(uout);  // Remove any trailing #0
            Result := UTF8Decode(uout);
        end;
    except
    end;
end;


end.

