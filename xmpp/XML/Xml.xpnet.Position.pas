unit Xml.xpnet.Position;

interface
type
  TPosition=class
  private
    _linenumber,_columnnumber:integer;
  public
    constructor Create();
    property LineNumber:Integer read _linenumber write _linenumber;
    property ColumnNumber:Integer read _columnnumber write _columnnumber;

  end;

implementation

{ TPosition }

constructor TPosition.Create;
begin
  _LineNumber:=1;
  _columnnumber:=0;
end;

end.
