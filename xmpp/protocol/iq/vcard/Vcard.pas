unit Vcard;

interface
uses
  Element,NativeXml,XmppUri,jid,name,Organization,photo,Address,Telephone,email,SysUtils,Classes;
type
  TVcard=class(TElement)
  private
    function FGetUrl:string;
    procedure FSetUrl(value:string);
    function FGetBirthday:TDateTime;
    procedure FSetBirthday(value:TDateTime);
    function FGetTitle:string;
    procedure FSetTitle(value:string);
    function FGetRole:string;
    procedure FSetRole(value:string);
    function FGetFullname:string;
    procedure FSetFullname(value:string);
    function FGetNickname:string;
    procedure FSetNickname(value:string);
    function FGetJabberId:TJid;
    procedure FSetJabberId(value:TJid);
    function FGetDescription:string;
    procedure FSetDescription(value:string);
    function FGetTName:TName;
    procedure FSetTName(value:TName);
    function FGetOrganization:TOrganization;
    procedure FSetOrganization(value:TOrganization);
    function FGetPhoto:TPhoto;
    procedure FSetPhoto(value:TPhoto);
  public
    constructor Create();override;
    property Url:string read FGetUrl write FSetUrl;
    property Birthday:TDateTime read FGetBirthday write FSetBirthday;
    property Title:string read FGetTitle write FSetTitle;
    property Role:string read FGetRole write FSetRole;
    property Fullname:string read FGetFullname write FSetFullname;
    property Nickname:string read FGetNickname write FSetNickname;
    property JabberId:TJid read FGetJabberId write FSetJabberId;
    property Description:string read FGetDescription write FSetDescription;
    property VName:TName read FGetTName write FSetTName;
    property Photo:TPhoto read FGetPhoto write FSetPhoto;
    property Organization:TOrganization read FGetOrganization write FSetOrganization;
    procedure GetAddresses(const el:TList);
    function GetAddresss(loc:string):TAddress;
    procedure AddAddress(addr:TAddress);
    function GetPreferedAddress():TAddress;
    procedure GetTelephoneNumbers(const al:TList);
    function GetTelephoneNumber(tp:string;loc:string):TTelephone;
    procedure AddTelephoneNumber(tel:TTelephone);
    procedure AddEmailAddress(mail:TEmail);
    procedure GetEmailAddresses(const al:TList);
    function GetEmailAddress(tp:string):Temail;
    function GetPreferedEmailAddress():TEmail;
  end;
var
  TagName:string='vCard';
implementation

{ TVcard }

procedure TVcard.AddAddress(addr: TAddress);
var
  a:TAddress;
begin
  a:=GetAddresss(Addr.Location);
  if(a<>nil)then
    NodeRemove(a);
  NodeAdd(Addr);

end;

procedure TVcard.AddEmailAddress(mail: TEmail);
var
  e:TEmail;
begin
  e:=GetEmailAddress(mail.EmailType);
  if(e<>nil)then
    NodeRemove(e);
  NodeAdd(mail);
end;

procedure TVcard.AddTelephoneNumber(tel: TTelephone);
var
  e:TTelephone;
begin
  e:=GetTelephoneNumber(tel.TelType,tel.Location);
  if(e<>nil)then
    NodeRemove(e);
  NodeAdd(tel);

end;

constructor TVcard.Create();
begin
  inherited Create();
  Name:='vCard';
  Namespace:=XMLNS_VCARD;
end;

function TVcard.FGetBirthday: TDateTime;
var
  s:string;
begin
  //{ TODO : ÐèÒªCatch }
  s:=GetTag('BDAY');
  if s<>'' then
    Result:=StrToDateTime(s)
  else
    Result:=MinDateTime;
end;

function TVcard.FGetDescription: string;
begin
  Result:=GetTag('DESC');
end;

function TVcard.FGetFullname: string;
begin
  Result:=GetTag('FN');
end;

function TVcard.FGetJabberId: TJid;
begin
  Result:=TJID.Create(GetTag('JABBERID'));
end;

function TVcard.FGetNickname: string;
begin
  Result:=GetTag('NICKNAME');
end;

function TVcard.FGetOrganization: TOrganization;
begin
  Result:=TOrganization(findnode('ORG'));
end;

function TVcard.FGetPhoto: TPhoto;
begin
  Result:=TPhoto(findnode('PHOTO'));
end;

function TVcard.FGetRole: string;
begin
  Result:=GetTag('ROLE');
end;

function TVcard.FGetTitle: string;
begin
  Result:=GetTag('TITLE');
end;

function TVcard.FGetTName: TName;
begin
  Result:=TName(findnode('N'));
end;

function TVcard.FGetUrl: string;
begin
  Result:=GetTag('URL');
end;

procedure TVcard.FSetBirthday(value: TDateTime);
begin
  NodeFindOrCreate('BDAY').Value:=DateToStr(value);
end;

procedure TVcard.FSetDescription(value: string);
begin
  NodeFindOrCreate('DESC').Value:=value;
end;

procedure TVcard.FSetFullname(value: string);
begin
  NodeFindOrCreate('FN').Value:=value;
end;

procedure TVcard.FSetJabberId(value: TJid);
begin
  NodeFindOrCreate('JABBERID').Value:=value.ToString;
end;

procedure TVcard.FSetNickname(value: string);
begin
  NodeFindOrCreate('NICKNAME').Value:=value;
end;

procedure TVcard.FSetOrganization(value: TOrganization);
var
  e:TOrganization;
begin
  e:=TOrganization(findnode('ORG'));
  if(e<>nil)then
    NodeRemove(e);
  NodeAdd(value);
end;

procedure TVcard.FSetPhoto(value: TPhoto);
var
  e:TPhoto;
begin
  e:=TPhoto(findnode('PHOTO'));
  if(e<>nil)then
    NodeRemove(e);
  NodeAdd(value);
end;

procedure TVcard.FSetRole(value: string);
begin
  NodeFindOrCreate('ROLE').Value:=value;
end;

procedure TVcard.FSetTitle(value: string);
begin
  NodeFindOrCreate('TITLE').Value:=value;
end;

procedure TVcard.FSetTName(value: TName);
var
  e:TName;
begin
  e:=TName(findnode('N'));
  if(e<>nil)then
    NodeRemove(e);
  NodeAdd(value);
end;

procedure TVcard.FSetUrl(value: string);
begin
  NodeFindOrCreate('URL').Value:=value;
end;

procedure TVcard.GetAddresses(const el: TList);
begin
    //el:=TList.Create;
  FindNodes('ADR',el);
end;

function TVcard.GetAddresss(loc: string): TAddress;
var
  el:TList;
  i:integer;
begin
el:=TList.Create;
  GetAddresses(el);
  for i := 0 to el.Count-1 do
    if TAddress(el[i]).Location=loc then
    begin
      Result:=el[i];
      Exit;
    end;
  Result:=nil;
end;

function TVcard.GetEmailAddress(tp: string): Temail;
var
  el:TList;
  i:integer;
begin
el:=TList.Create;
  GetEmailAddresses(el);
  for i := 0 to el.Count-1 do
    if Temail(el[i]).EmailType=tp then
    begin
      Result:=el[i];
      Exit;
    end;
  Result:=nil;

end;

procedure TVcard.GetEmailAddresses(const al:TList);
begin

  findnodes(email.TagName,al);
end;

function TVcard.GetPreferedAddress: TAddress;
var
  el:TList;
  i:integer;
begin
  el:=TList.Create;
  GetAddresses(el);
  for i := 0 to el.Count-1 do
    if TAddress(el[i]).IsPrefered then
    begin
      Result:=el[i];
      Exit;
    end;
  Result:=nil;
end;

function TVcard.GetPreferedEmailAddress: TEmail;
var
  el:TList;
  i:integer;
begin
  el:=TList.Create;
  GetEmailAddresses(el);
  for i := 0 to el.Count-1 do
    if Temail(el[i]).IsPrefered then
    begin
      Result:=el[i];
      Exit;
    end;
  Result:=nil;
end;

function TVcard.GetTelephoneNumber(tp: string;
  loc: string): TTelephone;
var
  el:TList;
  i:integer;
begin
  el:=TList.Create;
  GetTelephoneNumbers(el);
  for i := 0 to el.Count-1 do
    if (TTelephone(el[i]).TelType=tp) and (TTelephone(el[i]).Location=loc) then
    begin
      Result:=el[i];
      Exit;
    end;
  Result:=nil;
end;

procedure TVcard.GetTelephoneNumbers(const al:TList);
begin
  FindNodes(Telephone.TagName,al);
end;

end.
