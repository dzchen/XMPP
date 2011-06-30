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
unit XMLTag;


interface

uses

    XMLNode,
    XMLAttrib,
    XMLCData,

    Classes, SyncObjs, 
    Contnrs;

type
  {---------------------------------------}
  {          TXMLTag Main Class Def       }
  {---------------------------------------}
  TXMLTag = class;
  TXPLite = class;

  TXMLNodeList = class(TObjectList)
  end;

  TXMLTagList = class(TList)
    private
        function GetTag(index: integer): TXMLTag;
    public
        property Tags[index: integer]: TXMLTag read GetTag; default;
  end;

  TXMLTag = class(TXMLNode)
  private
    _AttrList: TAttrList;       // list of attributes
    _Children: TXMLNodeList; // list of nodes
    _ns: Utf8String;
    _xml_buff: Utf8String;
    _refs: integer;
    _lock: TCriticalSection;

  public
    pTag: TXMLTag;

    constructor Create; overload; override;
    constructor Create(tagname: Utf8String); reintroduce; overload; virtual;
    constructor Create(tag: TXMLTag); reintroduce; overload; virtual;
    constructor Create(tagname, CDATA: Utf8String); reintroduce; overload; virtual;
    destructor Destroy; override;

    procedure AddRef();
    procedure Release();

    function AddTag(tagname: Utf8String): TXMLTag; overload;
    function AddTag(child_tag: TXMLTag): TXMLTag; overload;
    function AddTagNS(tagname: Utf8String; xmlns: Utf8String): TXMLTag;

    function AddBasicTag(tagname, cdata: Utf8String): TXMLTag;
    function AddCData(content: Utf8String): TXMLCData;

    function GetAttribute(key: Utf8String): Utf8String;
    procedure setAttribute(key, value: Utf8String);
    procedure removeAttribute(key: Utf8String);

    function ChildCount: integer;
    function ChildTags: TXMLTagList;
    function QueryXPTags(path: Utf8String): TXMLTagList; overload;
    function QueryXPTags(xp: TXPLite): TXMLTagList; overload;
    function QueryXPTag(path: Utf8String): TXMLTag; overload;
    function QueryXPTag(xp: TXPLite): TXMLTag; overload;
    function QueryXPData(path: Utf8String): Utf8String;
    function QueryTags(key: Utf8String): TXMLTagList;
    function QueryRecursiveTags(key: Utf8String; first: boolean = false): TXMLTagList;
    function GetFirstTag(key: Utf8String): TXMLTag;
    function GetBasicText(key: Utf8String): Utf8String;
    function TagExists(key: Utf8String): boolean;

    function Data: Utf8String;
    function Namespace(children: boolean = false): Utf8String;
    function XML: Utf8String; override;

    procedure ClearTags;
    procedure ClearCData;
    procedure RemoveTag(node: TXMLTag);
    procedure AssignTag(const xml: TXMLTag);

    procedure addInsertedXML(inserted_xml: Utf8String);

    property Attributes: TAttrList read _AttrList;
    property Nodes: TXMLNodeList read _Children;
  end;

  TXPPredicateOp = (XPP_EQUAL, XPP_NOTEQUAL, XPP_EXISTS, XPP_NOTEXISTS, XPP_VALUE);

  TXPPredicate = class
  public
    name: Utf8String;
    value: Utf8String;
    op: TXPPredicateOp;
    
    constructor Create(pname, pvalue: Utf8String; pop: TXPPredicateOp);
  end;

  TXPMatch = class
  private
    _PredList: TStringlist;
    function GetPredCount: integer;
  public
    tag_name: Utf8String;
    get_cdata: boolean;
    recursive: boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Parse(xps: Utf8String);
    procedure setPredicate(name, value: Utf8String; op: TXPPredicateOp);
    function getPredicate(i: integer): TXPPredicate;

    property PredCount: integer read GetPredCount;
    property PredList: TStringlist read _PredList;
  end;

  TXPLite = class
  private
    Matches: TStringList;
    attr: Utf8String;
    value: Utf8String;
    function GetString: Utf8String;
    function checkTags(Tag: TXMLTag; match_idx: integer; first: boolean = false): TXMLTagList;
    function doCompare(tag: TXMLTag; start: integer): boolean;
  public
    Constructor Create(xps: Utf8String = '');
    Destructor Destroy; override;
    procedure Parse(xps: Utf8String);
    function Compare(Tag: TXMLTag): boolean;
    function Query(Tag: TXMLTag): Utf8String;
    function GetTags(tag: TXMLTag; first: boolean = false): TXMLTagList;

    property AsString: Utf8String read GetString;
    property XPMatchList: TStringList read Matches;
  end;


implementation

uses

    XMLUtils,
    SysUtils;

function TXMLTagList.GetTag(index: integer): TXMLTag;
begin
    if (index >= 0) and (index < Count) then
        Result := TXMLTag(Items[index])
    else
        Result := nil;
end;

{---------------------------------------}
{---------------------------------------}
{  TXMLTag  Class Implmenetation        }
{---------------------------------------}
{---------------------------------------}

constructor TXMLTag.Create;
begin
    // Create the object
    inherited;

    NodeType := xml_tag;
    _AttrList := TAttrList.Create();
    _Children := TXMLNodeList.Create(true);
    _xml_buff := '';
    _refs := 0;
    _lock := nil;

    pTag := nil;
end;

{---------------------------------------}
constructor TXMLTag.Create(tagname: Utf8String);
begin
    //
    Create();
    Name := tagname;
end;

{---------------------------------------}
constructor TXMLTag.Create(tag: TXMLTag);
begin
    //
    Create();
    Self.AssignTag(tag);
end;

{---------------------------------------}
constructor TXMLTag.Create(tagname, CDATA: Utf8String);
begin
    Create(tagname);
    self.AddCData(CDATA);
end;

{---------------------------------------}
destructor TXMLTag.Destroy;
begin
    // Free everything for this node
    _AttrList.Clear;
    _AttrList.Free;
    _Children.Clear;
    _Children.Free;

    inherited Destroy;
end;

{---------------------------------------}
procedure TXMLTag.Release();
begin
    if (_lock = nil) then begin
        Self.Free();
        exit;
    end;

    _lock.Acquire();
    if (_refs = 0) then begin
        _lock.Release();
        inherited Free;
    end
    else begin
        Dec(_refs);
        _lock.Release();
    end;
end;

{---------------------------------------}
procedure TXMLTag.AddRef();
begin
    if (_lock = nil) then
        _lock := TCriticalSection.Create();

    _lock.Acquire();
    Inc(_refs);
    _lock.Release();
end;

{---------------------------------------}
function TXMLTag.AddTag(tagname: Utf8String): TXMLTag;
var
    t: TXMLTag;
begin
    // Add a tag
    t := TXMLTag.Create;
    t.Name := tagname;
    t.pTag := Self;
    _Children.Add(t);
    Result := t;
end;

{---------------------------------------}
function TXMLTag.AddTag(child_tag: TXMLTag): TXMLTag;
begin
    _Children.Add(child_tag);
    Result := child_tag;
end;

{---------------------------------------}
function TXMLTag.AddTagNS(tagname: Utf8String; xmlns: Utf8String): TXMLTag;
begin
    Result := AddTag(tagname);
    Result.setAttribute('xmlns', xmlns);
end;

{---------------------------------------}
function TXMLTag.AddBasicTag(tagname, cdata: Utf8String): TXMLTag;
var
    t: TXMLTag;
begin
    t := AddTag(tagname);
    t.pTag := Self;
    t.AddCData(cdata);
    Result := t;
end;

{---------------------------------------}
procedure TXMLTag.ClearTags;
var
    i: integer;
    n: TXMLNode;
begin
    // clear out all child tags
    for i := _children.Count - 1 downto 0 do begin
        n := TXMLNode(_children[i]);
        if n is TXMLTag then
            _children.Delete(i);
    end;
end;

{---------------------------------------}
procedure TXMLTag.RemoveTag(node: TXMLTag);
var
    i: integer;
begin
    // remove this tag
    i := _Children.IndexOf(node);
    if (i >= 0) then
        _children.Delete(i);
end;

{---------------------------------------}
procedure TXMLTag.ClearCData;
var
    i: integer;
    n: TXMLNode;
begin
    // clear out all child tags that are CDATA
    for i := _children.Count - 1 downto 0 do begin
        n := TXMLNode(_children[i]);
        if n is TXMLCDATA then
            _children.Delete(i);
    end;
end;

{---------------------------------------}
function TXMLTag.AddCData(content: Utf8String): TXMLCData;
var
    c: TXMLCData;
begin
    // Add the CData to the tag
    c := TXMLCData.Create(content);
    _Children.Add(c);
    Result := c;
end;

{---------------------------------------}
function TXMLTag.GetAttribute(key: Utf8String): Utf8String;
var
    attr: TNvpNode;
begin
    // get the attribute
    Result := '';
    attr := _AttrList.Node(key);
    if attr <> nil then
        Result := attr.Value;
end;

{---------------------------------------}
procedure TXMLTag.setAttribute(key, value: Utf8String);
var
    a: TNvpNode;
begin
    // Setup an attribute key value pair
    a := _AttrList.Node(key);
    if a = nil then begin
        a := TAttr.Create(key, value);
        _AttrList.Add(a);
    end
    else
        a.value := value;
end;

{---------------------------------------}
procedure TXMLTag.removeAttribute(key: Utf8String);
var
    a: TNvpNode;
begin
    a := _AttrList.Node(key);
    if (a <> nil) then begin
        _AttrList.Remove(a);
    end;
end;

{---------------------------------------}
function TXMLTag.QueryXPTags(xp: TXPLite): TXMLTagList;
begin
    Result := xp.GetTags(Self);
end;

{---------------------------------------}
function TXMLTag.QueryXPTags(path: Utf8String): TXMLTagList;
var
    xp: TXPLite;
begin
    // Return a tag list based on the xpath stuff
    xp := TXPLite.Create(path);
    Result := xp.GetTags(Self);
    xp.Free;
end;

{---------------------------------------}
function TXMLTag.QueryXPTag(xp: TXPLite): TXMLTag;
var
    tl: TXMLTagList;
begin
    tl := xp.GetTags(Self, true);
    if (tl.Count <= 0) then
        Result := nil
    else
        Result := tl[0];
    tl.Free();
end;

{---------------------------------------}
function TXMLTag.QueryXPTag(path: Utf8String): TXMLTag;
var
    xp: TXPLite;
begin
    // Return a tag based on the xpath stuff
    xp := TXPLite.Create(path);
    Result := QueryXPTag(xp);
    xp.Free;
end;

{---------------------------------------}
function TXMLTag.QueryXPData(path: Utf8String): Utf8String;
var
    i: integer;
    spath, att: Utf8String;
    ftags: TXMLTagList;
    t: TXMLTag;
begin
    // Return a Utf8String based on the xpath stuff
    att := '';
    spath := path;
    Result := '';

    // check to see if we are getting an attribute "/foo/bar@attribute"
    i := length(path);
    while (i >= 1) do begin
        if (path[i] = '@') then begin
            att := Copy(path, i + 1, length(path) - i);
            spath := Copy(path, 1, i-1);
            break;
        end
        else if (path[i] = '/') then
            break;
        dec(i);
    end;

    if (att <> '') then begin
        t := Self.QueryXPTag(spath);
        if (t <> nil) then
            Result := t.GetAttribute(att)
        else
            Result := '';
    end
    else begin
        ftags := Self.QueryXPTags(spath);
        for i := 0 to ftags.Count - 1 do
            Result := Result + ftags.tags[i].Data;
        ftags.Free();
    end;
end;

{---------------------------------------}
function TXMLTag.ChildCount: integer;
begin
    Result := _children.Count;
end;

{---------------------------------------}
function TXMLTag.ChildTags: TXMLTagList;
var
    t: TXMLTagList;
    n: TXMLNode;
    i: integer;
begin
    // return a list of all child elements
    t := TXMLTagList.Create();
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if (n.IsTag) then
            t.Add(TXMLTag(n));
    end;
    Result := t;
end;


{---------------------------------------}
function TXMLTag.QueryTags(key: Utf8String): TXMLTagList;
var
    t: TXMLTagList;
    n: TXMLNode;
    sname: Utf8String;
    i: integer;
begin
    // Return all of the immediate children which
    // have the specified tag name
    t := TXMLTagList.Create();
    sname := Trim(key);
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if ((n.IsTag) and (NameMatch(sname, n.name))) then
            t.Add(TXMLTag(n));
    end;

    Result := t;
end;

{---------------------------------------}
function TXMLTag.QueryRecursiveTags(key: Utf8String;
    first: boolean): TXMLTagList;
var
    c, s, t: TXMLTagList;
    j, i: integer;
begin
    // look recursively for all tags named key
    t := Self.QueryTags(key);

    if (t.Count = 0) or (not first) then begin
        c := Self.ChildTags();

        for i := 0 to c.Count - 1 do begin
            if (t.IndexOf(c[i]) = -1) then begin
                s := c[i].QueryRecursiveTags(key, first);
                for j := 0 to s.count - 1 do begin
                    t.Add(s[j]);
                    if (first) then break;
                end;
                if (s <> nil) then s.Free();
            end;
        end;
        if (c <> nil) then c.Free();
    end;
    Result := t;
end;

{---------------------------------------}
function TXMLTag.TagExists(key: Utf8String): boolean;
begin
    Result := (GetFirstTag(key) <> nil);
end;

{---------------------------------------}
function TXMLTag.GetFirstTag(key: Utf8String): TXMLTag;
var
    sname: Utf8String;
    i: integer;
    n: TXMLNode;
begin
    Result := nil;
    sname := Trim(key);
    assert(_children <> nil);
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if ((n.IsTag) and (NameMatch(sname, n.name))) then begin
            Result := TXMLTag(n);
            exit;
        end;
    end;
end;

{---------------------------------------}
function TXMLTag.GetBasicText(key: Utf8String): Utf8String;
var
    t: TXMLTag;
begin
    t := self.GetFirstTag(key);
    if (t <> nil) then
        Result := t.Data
    else
        Result := '';
end;

{---------------------------------------}
function TXMLTag.Data: Utf8String;
var
    i: integer;
    n: TXMLNode;
begin
    // add all CData together
    Result := '';
    for i := 0 to _Children.Count - 1 do begin
        n := TXMLNode(_Children[i]);
        if (n.NodeType = xml_CDATA) then begin
            Result := Result + TXMLCData(n).Data + ' ';
            break;
        end;
    end;
    if Result <> '' then Result := Trim(Result);
end;

{---------------------------------------}
function TXMLTag.Namespace(children: boolean = false): Utf8String;
var
    n:  TXMLNode;
    i:  integer;
begin
    // find the namespace for this tag
    if _ns = '' then begin
        if (not children) then
            _ns := Self.GetAttribute('xmlns');
        if _ns = '' then begin
            // check thru all the tag elements
            for i := 0 to _Children.Count - 1 do begin
                n := TXMLNode(_Children[i]);
                if (n.NodeType = xml_Tag) then begin
                    _ns := TXMLTag(n).GetAttribute('xmlns');
                    if _ns <> '' then
                        break;
                end;
            end;
        end;
    end;
    Result := _ns;
end;

{---------------------------------------}
procedure TXMLTag.addInsertedXML(inserted_xml: Utf8String);
begin
    // append xtra stuff into the _xml_buff
    _xml_buff := _xml_buff + inserted_xml;
end;

{---------------------------------------}
function TXMLTag.xml: Utf8String;
var
    i: integer;
    x: Utf8String;
begin
    // Return a Utf8String containing the full
    // representation of this tag
    x := '<' + Self.Name;
    for i := 0 to _AttrList.Count - 1 do
        x := x + ' ' + _AttrList.Name(i) + '="' +
            XML_EscapeChars(_AttrList.Value(i)) + '"';

    if ((_Children.Count = 0) and (_xml_buff = '')) then
        x := x + '/>'
    else begin
        // iterate over all the children
        x := x + '>';
        for i := 0 to _Children.Count - 1 do
            x := x + TXMLNode(_Children[i]).xml;
        x := x + _xml_buff;
        x := x + '</' + Self.name + '>';
    end;
    Result := x;
end;

{---------------------------------------}
procedure TXMLTag.AssignTag(const xml: TXMLTag);
var
    i: integer;
    c: TXMLTag;
    tags: TXMLNodeList;
    n: TXMLNode;
begin
    // Make self contain all the info that xml does

    // NOTE: mixed content may now exist (XHTML)
    Self.Name := xml.Name;
    tags := xml.Nodes;

    for i := 0 to tags.Count - 1 do begin
        n := TXMLNode(tags[i]);
        if (n.NodeType = xml_Tag) then begin
            c := Self.AddTag(TXMLTag(n).Name);
            c.AssignTag(TXMLTag(n));
        end
        else if (n.NodeType = xml_CDATA) then begin
            Self.AddCData(TXMLCData(n).Data)
        end;
    end;

    for i := 0 to xml._AttrList.Count - 1 do
        Self.setAttribute(xml._AttrList.Name(i), xml._AttrList.Value(i));
    //copy xml buff as well        
    _xml_buff := xml._xml_buff;        
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
constructor TXPPredicate.Create(pname, pvalue: Utf8String; pop: TXPPredicateOp);
begin
    name := pname;
    value := pvalue;
    op := pop;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
constructor TXPMatch.Create;
begin
    inherited;

    _PredList := Stringlist.Create();
    tag_name := '';
    get_cdata := false;
    recursive := false;
end;

{---------------------------------------}
destructor TXPMatch.Destroy;
var
    i: integer;
begin
    //
    for i := 0 to _PredList.Count - 1 do begin
        if (_PredList.Objects[i] <> nil) then
            TObject(_PredList.Objects[i]).Free();
    end;
    _PredList.Free();

    inherited Destroy;
end;

{---------------------------------------}
procedure TXPMatch.setPredicate(name, value: Utf8String; op: TXPPredicateOp);
var
    pred: TXPPredicate;
begin
    // specify an attribute on the tag.
    pred := TXPPredicate.Create(name, value, op);
    _PredList.AddObject(name, pred);
end;

{---------------------------------------}
function TXPMatch.getPredicate(i: integer): TXPPredicate;
begin
    if ((i >= 0) and (i < _PredList.Count)) then
        Result := TXPPredicate(_PredList.Objects[i])
    else
        Result := nil;
end;

{---------------------------------------}
function TXPMatch.GetPredCount: integer;
begin
    Result := _PredList.Count;
end;

{---------------------------------------}
procedure TXPMatch.Parse(xps: Utf8String);
var
    l, i, s: integer;
    state: integer;
    ptype, op, xp, q, name, val, c, cur: Utf8String;
begin
    // this should be a single "block"
    // parse the /foo[@a="b"][@c="d"] stuff
    // could be: /foo@a also to just get the attribute
    // could also be: //foo[@a="b"]

    // deal with other operators for predicates:
    // /foo[!a] for an element named foo, with NO attribute named a
    // /foo[@a!="b"] for an element named foo, wgere the attr a does NOT eq. b
    i := 2;
    xp := Trim(xps);
    l := Length(xp);
    state := 0;
    cur := '';

    if ((l > 2) and (xp[1] = '/') and (xp[2] = '/')) then begin
        recursive := true;
        i := 3;
    end;

    while (i <= l) do begin
        c := xp[i];
        if (c = '[') then begin
            // this is a where clause
            if (state = 0) then
                tag_name := cur;
            inc(i); // should be pointing to '@' or '!'
            ptype := xp[i];
            inc(i); // should be pointing to first letter of attr
            s := i;
            while ((i <= l) and (xp[i] <> '=') and (xp[i] <> ']') and (xp[i] <> '!')) do
                inc(i);
            name := Copy(xp, s, (i-s));

            if (xp[i] = ']') then begin
                // check for exist or not exist of an attr
                if (ptype = '@') then
                    setPredicate(name, '', XPP_EXISTS)
                else if (ptype = '!') then
                    setPredicate(name, '', XPP_NOTEXISTS);
            end
            else begin
                // check = or != for an attribute
                if (xp[i] = '!') then begin
                    op := '!=';
                    inc(i); // point to =
                end;
                inc(i); // point to "
                q := xp[i];
                inc(i); // point to first letter

                // XXX: Please optimize me!
                // Scan ahead for the matching quote char to q.
                val := '';
                while (i <= l) do begin
                    if (xp[i] = '"') then begin
                        if ((i = l) or (xp[i+1] <> '"')) then
                            break
                        else
                            inc(i);
                    end;
                    val := val + xp[i];
                    inc(i);
                end;
                if (op = '!=') then
                    setPredicate(name, val, XPP_NOTEQUAL)
                else
                    setPredicate(name, val, XPP_EQUAL);
            end;
            state := 1;
            inc(i);
        end
        else if (c = '@') then begin
            // specific attribute
            if (state = 0) then
                tag_name := cur;
            inc(i); // should be pointing at the attribute name now
            s := i;
            while ((i <= l) and (xp[i] <> '@')) do
                inc(i);
            name := Copy(xp, s, (i-s));
            val := '';
            setPredicate(name, val, XPP_VALUE);
        end
        else if (state = 0) then
            cur := cur + c;
        inc(i);
    end;

    if (state = 0) then
        tag_name := cur;
end;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TXPLite.Create(xps: Utf8String = '');
begin
    inherited Create();
    attr := '';
    value := '';
    Matches := TStringList.Create;

    if (xps <> '') then
        parse(xps);
end;

{---------------------------------------}
destructor TXPLite.Destroy;
begin
    ClearStringListObjects(Matches);
    Matches.Free;

    inherited Destroy;
end;

{---------------------------------------}
procedure TXPLite.Parse(xps: Utf8String);
var
    s, l, i, f: integer;
    c, cur: Utf8String;
    m: TXPMatch;
begin
    // parse the full /foo/bar[@xmlns="jabber:iq:roster"] string
    {
    Could also be:
    /foo/bar/cdata
    /foo/bar@xmlns
    //x[@xmlns="jabber:x:data"]
    }
    ClearStringListObjects(Matches);
    s := 1;
    i := 2;
    l := Length(xps);
    if ((l >2 ) and (xps[2] = '/')) then i := 3;
    cur := '';
    c := '';
    m := nil;
    while (i <= l) do begin
        c := xps[i];

        if ((c = '"') or (c = Chr(39))) then begin
            // we are in a quote sequence, find the matching quote
            f := i + 1;
            while (f <= l) do begin
                if (xps[f] = '"') then begin
                    if ((f = l) or (xps[f+1] <> '"')) then
                        break
                    else
                        inc(f);
                end;
                inc(f);
            end;

            if (f <= l) then
                i := f;
        end;

        if ((c = '/') or (i = l)) then begin
            // we've reached a separator
            if (c = '/') then begin
                cur := Copy(xps, s, (i-s));
                s := i;
                if (xps[i+1] = '/') then inc(i);
            end
            else begin
                cur := Copy(xps, s, (i - s) + 1);
                s := i;
            end;

            if ((Lowercase(cur) = 'cdata') and (m <> nil)) then
                m.get_cdata := true
            else begin
                m := TXPMatch.Create;
                m.parse(cur);
                Matches.AddObject(m.tag_name, m)
            end;
        end;
        inc(i);
    end;
end;

{---------------------------------------}
function TXPLite.Query(Tag: TXMLTag): Utf8String;
begin
    //
    result := '';
end;

{---------------------------------------}
function TXPLite.checkTags(Tag: TXMLTag; match_idx: integer; first: boolean): TXMLTagList;
var
    cm: TXPMatch;
    cp: TXPPredicate;
    pp, i, p: integer;
    r, tl: TXMLTagList;
    t: TXMLTag;
    wild_card: boolean;
    tmps: Utf8String;
    add: boolean;
begin
    // find the tags that matches the specific TXPMatch object
    r := TXMLTagList.Create();
    cm := TXPMatch(Matches.Objects[match_idx]);

    // check tag names
    if (cm.recursive) then
        tl := Tag.QueryRecursiveTags(cm.tag_name, first)
    else if (match_idx = 0) then begin
        tl := TXMLTagList.Create();
        tl.Add(Tag);
    end
    // check to see if we have a wildcard tag name..
    else if (cm.tag_name = '*') then
        tl := Tag.ChildTags()
    else
        tl := Tag.QueryTags(cm.tag_name);

    // Check all the tags in the taglist
    for i := 0 to tl.Count - 1 do begin
        t := tl.Tags[i];
        add := false;

        // Check ea. tag for the appropriate tag name
        if ((cm.tag_name = '*') or (t.Name = cm.tag_name)) then begin
            add := true;

            // Check ea. tag to make sure it has the correct attributes
            for p := 0 to cm.PredCount - 1 do begin
                cp := cm.getPredicate(p);
                case cp.op of
                XPP_EXISTS: begin
                    if (t.GetAttribute(cp.Name) = '') then add := false;
                end;
                XPP_NOTEXISTS: begin
                    if (t.getAttribute(cp.Name) <> '') then add := false;
                end;
                XPP_EQUAL, XPP_NOTEQUAL: begin
                    wild_card := (Copy(cp.Value, length(cp.Value), 1) = '*');
                    if wild_card then begin
                        tmps := cp.Value;
                        Delete(tmps, length(tmps), 1);
                        pp := Pos(Lowercase(tmps), Lowercase(t.getAttribute(cp.Name)));
                        if ((cp.op = XPP_EQUAL) and (pp <> 1)) then
                            add := false
                        else if ((cp.op = XPP_NOTEQUAL) and (pp = 1)) then
                            add := false;
                    end

                    // XXX: Need a better way to do jid's eventually..
                    // We are lcasing here so jids match.
                    else if ((cp.op = XPP_EQUAL) and
                    (Lowercase(t.getAttribute(cp.Name)) <> Lowercase(cp.Value))) then
                        add := false
                    else if ((cp.op = XPP_NOTEQUAL) and
                    (Lowercase(t.getAttribute(cp.Name)) = Lowercase(cp.Value))) then
                        add := false;
                end;
                end;
            end;
        end;

        // If the add flag is still true, add the tag to the result set
        if (add) then
            r.Add(t);
    end;
    tl.Free();
    
    Result := r;
end;

{---------------------------------------}
function TXPLite.GetTags(tag: TXMLTag; first: boolean): TXMLTagList;
var
    t: TXMLTag;
    c, i, m: integer;
    r, ntags, ctags, mtags: TXMLTagList;
begin
    {
    Iteratively search the xplite looking for tags
    that match. We want to return a list of all
    the matching tags
    }
    m := 0;
    t := tag;
    r := TXMLTagList.Create();
    ctags := TXMLTagList.Create();
    ntags := TXMLTagList.Create();

    // compile the list of tags that match the entire xplite
    ctags.Add(t);
    repeat
        for c := 0 to ctags.Count - 1 do begin
            mtags := checkTags(ctags[c], m, first);
            if (m = Matches.Count - 1) then begin
                ntags.Clear;
                for i := 0 to mtags.Count - 1 do
                    r.add(mtags.tags[i]);
            end
            else begin
                for i := 0 to mtags.Count - 1 do
                    ntags.Add(mtags[i]);
            end;
            mtags.Free;
        end;
        inc(m);
        ctags.Assign(ntags);
        ntags.Clear;
        if ((first) and (r.Count > 0)) then break;
    until (m >= Matches.Count) or (ntags.Count < 0);
    ntags.Free;
    ctags.Free;

    Result := r;
end;

{---------------------------------------}
function TXPLite.doCompare(tag: TXMLTag; start: integer): boolean;
var
    t, next: integer;
    mtags: TXMLTagList;
begin
    // check this tag and subsequent ones against the start match
    mtags := checkTags(tag, start);

    if (mtags.Count > 0) then begin
        // we have matching tags
        next := start + 1;
        if (next = Matches.Count) then begin
            // we have successfully matched everything
            Result := true;
        end
        else begin
            // Check the next level
            Result := true;
            for t := 0 to mtags.Count - 1 do
                Result := Result and (doCompare(mtags.Tags[t], next));
        end;
    end
    else
        Result := false;

    mtags.Free;
end;

{---------------------------------------}
function TXPLite.Compare(Tag: TXMLTag): boolean;
begin
    // compare a tag against this XPLite object
    if (Matches.Count <= 0) then begin
        Result := true;
        exit;
    end;

    // check the first level, and kick off doCompares
    Result := doCompare(Tag, 0);
end;

{---------------------------------------}
function TXPLite.GetString: Utf8String;
var
    m: TXPMatch;
    cp: TXPPredicate;
    p, i: integer;
begin
    // get the xplite string representation
    Result := '';

    for i := 0 to Matches.Count - 1 do begin
        m := TXPMatch(Matches.Objects[i]);
        Result := Result + '/' + m.tag_name;

        for p := 0 to m.PredCount - 1 do begin
            cp := m.getPredicate(p);
            case cp.op of
            XPP_VALUE:      Result := Result + '@' + cp.Name;
            XPP_EXISTS:     Result := Result + '[@' + cp.Name + ']';
            XPP_NOTEXISTS:  Result := Result + '[!' + cp.Name + ']';
            XPP_EQUAL:      Result := Result + '[@' + cp.Name + '="' + cp.Value + '"]';
            XPP_NOTEQUAL:   Result := Result + '[@' + cp.Name + '!="' + cp.Value + '"]';
            end;
        end;
    end;
end;

end.
