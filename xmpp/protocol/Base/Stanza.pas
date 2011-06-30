unit Stanza;

interface
uses
  DirectionalElement;
type
  TStanza=class(TDirectionalElement)
  private
    procedure FSetId(value:string);
    function FGetId:string;
    procedure FSetLanguage(value:string);
    function FGetLanguage:string;
  public
    property Id: string read FGetId write FSetId;
    property Language: string read FGetLanguage write FSetLanguage;
    procedure GenerateId();
  end;

implementation

{ TStanza }

function TStanza.FGetId: string;
begin

end;

function TStanza.FGetLanguage: string;
begin

end;

procedure TStanza.FSetId(value: string);
begin

end;

procedure TStanza.FSetLanguage(value: string);
begin

end;

procedure TStanza.GenerateId;
begin

end;

end.
