unit Xml.Dom.Node;

interface
uses
  XMPPConst,Xml.Dom.NodeList;
type
  TNode=class
  private
    _nodetype:TNodeType;
    _value,_namespace:string;
    _childNodes:TNodeList;
    procedure WriteTree(e:Tnode;
  protected
    Parent:TNode;
    _index:Integer;
  public
    property NodeType:TNodetype read _nodetype write _nodetype;
    property Value:string read _value write _value;
    property Namespace:string read _namespace write _namespace;
    property NodeIndex:Integer read _index;
    property ChildNodes:TNodelist read _childnodes;
    procedure Remove();
    procedure RemoveAllChildNodes();
    procedure AddChild(e:TNode);virtual;
    function ToString():string;overload;
    //function ToString(enc:TEncoding):string;overload;

  end;

implementation

end.
