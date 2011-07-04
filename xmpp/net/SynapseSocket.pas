unit SynapseSocket;
{$IFDEF FPC}
{$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, blcksock, ssl_openssl, SyncObjs,Net.BaseSocket,XMPPEvent;

type
  TSynapseSocket=class;


  TTCPThread=class(TThread)
  private
    sock:TTCPBlockSocket;
    FOwner:TSynapseSocket;
    FData:string;
    FErrMsg:string;
  protected
    procedure Execute;override;
    procedure DoAfterConnect(Sender:TObject);
    procedure SyncOnConnect;
    procedure SyncOnDisconnect;
    procedure SyncOnData;
    procedure SyncOnError;
    procedure SyncAfterUpgradedToSSL;
    procedure SyncOnSSLFailed;
    procedure SockCallback(Sender: TObject; Reason: THookSocketReason;
        const Value: string);
  public
    constructor Create(AOwner:TSynapseSocket);
    destructor Destroy;override;
  end;


  TSynapseSocket=class(TBaseSocket)
  private
    FTCPHandle,
    FCommands:TList;

    FOnAfterSSL:TNotifyEvent;
    FOnSSLFailed:XmlHandler;

    FCS:TCriticalSection;
    _address:string;
    _port:Integer;
    FConnected:Boolean;
    _sstls:Boolean;
    _ssl:Boolean;
    _compressed:Boolean;
  protected
    procedure CreateTCPThread;
    procedure FreeTCPThread;
    procedure PushCommand(Value:TTCPCommand);
    function  PopCommand:TTCPCommand;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Connect;
    procedure Disconnect;
    function  IsConnected:Boolean;

    procedure UpgradeConnectionWithOpenSSL;
//    procedure DowngradeSSLConnection;

    procedure Send(Data:string);overload;override;

    property Address:string read _address write _address;
    property Port:integer read _port write _port;
    property SSL:Boolean read _ssl write _ssl;
    property SupportsStartTls:Boolean read _sstls;
    property Connected:Boolean read IsConnected;
    property Compressed:Boolean read _compressed write _compressed;

    property OnAfterUpgradedToSSL:TNotifyEvent read FOnAfterSSL write FOnAfterSSL;
    property OnSSLFailed:XmlHandler read FOnSSLFailed write FOnSSLFailed;
    procedure StartTls();override;
    procedure StartCompression;override;
  end;

implementation

{ TTCPThread }

constructor TTCPThread.Create(AOwner:TSynapseSocket);
begin
  inherited Create(True);
  FOwner := AOwner;
  sock := TTCPBlockSocket.CreateWithSSL(TSSLOpenSSL);
  sock.OnAfterConnect := DoAfterConnect;
  sock.OnStatus := SockCallback;
end;

destructor TTCPThread.Destroy;
begin
  sock.Free;
  inherited;
end;

procedure TTCPThread.SockCallback(Sender: TObject;
  Reason: THookSocketReason; const Value: string);
begin
  case Reason of
  HR_Error,HR_SocketClose:
    begin
      if FOwner.FConnected then
        Synchronize(SyncOnDisconnect)
      else begin
        FErrMsg := Value;
        if Length(FErrMsg)>0 then
          Synchronize(SyncOnError);
      end;
    end;
  end;
end;

procedure TTCPThread.DoAfterConnect(Sender: TObject);
begin
  Synchronize(SyncOnConnect);
end;

procedure TTCPThread.SyncOnConnect;
begin
  FOwner.FConnected := True;
  FOwner.FireOnConnect;
end;

procedure TTCPThread.SyncOnData;
begin
  FOwner.FireOnReceive(fdata);
end;

procedure TTCPThread.SyncOnDisconnect;
begin
  FOwner.FConnected := False;
  fowner.FireOnDisconnect;
end;

procedure TTCPThread.SyncOnError;
begin
  FOwner.FireOnError(Exception.Create(FErrMsg));
end;

procedure TTCPThread.SyncAfterUpgradedToSSL;
begin
  if Assigned(FOwner.OnAfterUpgradedToSSL) then
    FOwner.FOnAfterSSL(FOwner);
end;

procedure TTCPThread.SyncOnSSLFailed;
begin
  if Assigned(FOwner.OnSSLFailed) then
    FOwner.FOnSSLFailed(FOwner,FErrMsg);
end;

procedure TTCPThread.Execute;
const
  YAHOO_DATA_MAX = 65535 +20;
var
  J,C:TTCPCommand;
  s:string;
  x:integer;
  bt:TBytes;
begin
  while not Terminated do begin
    J := FOwner.PopCommand;
    if Assigned(J) then
    begin
      if (TTCPCommand(J).Status=tsConnect) then
      begin
        sock.Connect(J.Info.Host,inttostr(J.Info.Port));
        while (sock.LastError=0) and (not Terminated) do
        begin
          C := FOwner.PopCommand;
          if Assigned(C) then begin
            case TTCPCommand(C).Status of
              tsDisconnect:
                begin
                  sock.CloseSocket;
                  Break;
                end;
              tsSSLConnect:
                begin
                  sock.SSLDoConnect;
                  if sock.SSL.LastError=0 then
                    Synchronize(SyncAfterUpgradedToSSL)
                  else begin
                    FErrMsg := sock.SSL.LastErrorDesc;
                    if Length(FErrMsg)>0 then
                      Synchronize(SyncOnSSLFailed);
                  end;
                end;
              tsData:
                sock.SendString(TTCPCommand(C).Data);
            end;
            C.Free;
          end;
          if sock.CanRead(20) then
          begin
            x:=sock.WaitingData;
            if x>0 then
            begin
              SetLength(bt,x);
              x:=sock.RecvBuffer(bt,x);
              SetLength(bt,x);
              fdata:=utf8.GetString(bt);
              if (sock.LastError=0) and (Length(FData)>0) then
              Synchronize(SyncOnData);
            end;

            {FData:= sock.RecvPacket(0);
            bt:=BytesOf(fdata);
            //FData:=AnsiToUtf8(fdata);
            FData:=utf8.GetString(BytesOf(fdata));
            if (sock.LastError=0) and (Length(FData)>0) then
              Synchronize(SyncOnData);   }
          end;
        end;
        sock.CloseSocket;
      end;
      J.Free;
    end else
    Sleep(200);
  end;
end;

{ TTCPClient }

constructor TSynapseSocket.Create;
begin
  inherited;
  FCS := TCriticalSection.Create;
  FTCPHandle := TList.Create;
  FCommands := TList.Create;
end;

destructor TSynapseSocket.Destroy;
var i:integer;
begin
  FreeTCPThread;
  FTCPHandle.Free;
  for i:=0 to FCommands.Count-1 do
    TTCPCommand(FCommands[i]).Free;
  FCommands.Free;
  FCS.Free;
  inherited;
end;

procedure TSynapseSocket.CreateTCPThread;
var FThread:TTCPThread;
begin
  FThread := TTCPThread.Create(Self);
  FThread.Resume;
  FTCPHandle.Add(FThread);
end;

procedure TSynapseSocket.FreeTCPThread;
var i:integer;
begin
  for i:=0 to FTCPHandle.Count-1 do
  begin
    TTCPThread(FTCPHandle[i]).Terminate;
    // TODO
    {$IFDEF WIN32}
    TTCPThread(FTCPHandle[i]).WaitFor;
    {$ENDIF}
    TTCPThread(FTCPHandle[i]).Free;
  end;
end;

procedure TSynapseSocket.Connect;
var C:TTCPCommand;
begin
  if FConnected then
    Exit;
  C := TTCPCommand.Create;
  C.Info.Host := _address;
  C.Info.Port := _port;
  C.Status := tsConnect;
  PushCommand(C);
end;

procedure TSynapseSocket.Disconnect;
var C:TTCPCommand;
begin
  if not FConnected then
    Exit;
  C := TTCPCommand.Create;
  C.Status := tsDisconnect;
  PushCommand(C);
end;

procedure TSynapseSocket.PushCommand(Value:TTCPCommand);
begin
  if FTCPHandle.Count < 1 then
    CreateTCPThread;
  FCS.Enter;
  FCommands.Add(Value);
  FCS.Leave;
end;

function TSynapseSocket.PopCommand: TTCPCommand;
begin
  FCS.Enter;
  if FCommands.Count>0 then
  begin
    Result := TTCPCommand(FCommands[0]);
    FCommands.Delete(0);
  end else
  Result := nil;
  FCS.Leave;
end;

function TSynapseSocket.IsConnected: Boolean;
begin
  Result := FConnected;
end;

procedure TSynapseSocket.Send(Data: string);
var C:TTCPCommand;
begin
  if not FConnected then
    Exit;
  C := TTCPCommand.Create;
  C.Status := tsData;
  C.Data := Data;
  PushCommand(C);
end;

procedure TSynapseSocket.StartCompression;
begin
  inherited;

end;

procedure TSynapseSocket.StartTls;
begin
  inherited;
  UpgradeConnectionWithOpenSSL;
end;

procedure TSynapseSocket.UpgradeConnectionWithOpenSSL;
var C:TTCPCommand;
begin
  if not FConnected then
    Exit;
  C := TTCPCommand.Create;
  C.Status := tsSSLConnect;
  PushCommand(C);
end;

// TODO
{
procedure TTCPClient.DowngradeSSLConnection;
var C:TTCPCommand;
begin
  if not FConnected then
    Exit;
  C := TTCPCommand.Create;
  C.Status := tsSSLDisconnect;
  PushCommand(C);
end;
}

end.

