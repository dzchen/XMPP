unit FieldContainer;

interface
uses
Element,NativeXml,XmppUri,Field,Generics.Collections;
type
  TFieldContainer=class(TElement)
  public
    function AddField:TField;overload;
    procedure AddField(field:TField);overload;
    function GetField(fieldvar:string):TField;overload;
    function GetFields():TList<TElement>;overload;
  end;

implementation

{ TFieldContainer }

function TFieldContainer.AddField: TField;
var
  f:TField;
begin
  f:=TField.Create;
  NodeAdd(f);
  Result:=f;
end;

procedure TFieldContainer.AddField(field: TField);
begin
  nodeadd(field);
end;

function TFieldContainer.GetField(fieldvar: string): TField;
var
  el:TList<Telement>;
  e:TElement;
begin
  el:=SelectElements(TField.ClassInfo);
  for e in el do
  begin
    if TField(e).FieldVar=fieldvar then
    begin
      result:=TField(e);
      Exit;
    end;
  end;

end;

function TFieldContainer.GetFields: TList<TElement>;
begin
  Result:=SelectElements(TField.ClassInfo);
end;

end.
