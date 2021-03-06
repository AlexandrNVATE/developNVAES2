library libicis;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  SysUtils,
  Classes,
  ScktComp,
  Dialogs,
  log4d,
  dllForm in 'dllForm.pas' {Form1};

{$R *.res}
  type
  TDetector = record
      localId:integer;
      serverId:integer;
      KKS:string;
      value:real;
      status:byte;
      end;


var
  f1: TForm1;
  clientSocket:TClientSocket;
  //������ ������� �������� ���� ������������� ��������� - ��������
  detectorList: array of TDetector;
  //����� ������� paramsRec
  lendetectorList:integer;
  currentIndex,current:integer;
  logger:TLogLogger;
  isOpenConnection:boolean;
  //������������� ����������� � ����������
  //���������� id �������

//����� ������� ������� �� ��������� idServer
function findIndexByServerID(index:integer):integer; cdecl;
var
  i:integer;
begin
  i:=0;
  while (i<lenDetectorList) and not (detectorList[i].serverId=index) do inc(i);
  if (i<lenDetectorList) and (detectorList[i].serverId=index) then findIndexByServerID:=i
  else findIndexByServerID:=-1;
end;

//����� ������� ������� �� ��������� localId
function findIndexByLocalID(index:integer):integer; cdecl;
var
  i:integer;
begin
  i:=0;
  while (i<lenDetectorList) and (detectorList[i].localId<>index) do inc(i);
  if (i<lenDetectorList) and (detectorList[i].localId=index) then findIndexByLocalID:=i
  else findIndexByLocalID:=-1;
end;

//������������� ����������
function InitModLib(name:Pchar): integer; cdecl;
var
  getId:integer;
begin
     getId:=1;

     clientSocket:=TClientSocket.Create(nil);
     f1:= TForm1.Create(nil);

     clientSocket.Name:= String(name);
     isOpenConnection:=true;
     TLogBasicConfigurator.Configure;
     TLogLogger.GetRootLogger.Level:= All;
     logger := TLogLogger.GetLogger('myLogger');
     logger.AddAppender(TLogFileAppender.Create('filelogger','log4d.log'));
     logger.Debug('initializing logging');
     
     InitModLib:=getId;
end;

//�������� ������ ����������� � ����������
//���������� id ����������
function CreateChannel(ClientID:integer;IPAdress:Pchar;Port:integer;TypeChannel:integer;Options:integer):integer;cdecl;
begin
    //������������� ����������
    clientSocket :=f1.clientSocket2;
    clientSocket.Port:=Port;
    clientSocket.ClientType:= ctNonBlocking;
    clientSocket.Address:=string(IPAdress);
    clientSocket.Active:=true;
    //������������� ������������� �������
    lendetectorList:=1;
    SetLength(detectorList,lendetectorList);
    CreateChannel :=1;
end;

//��������� id �� kks �����
//���������� ��������� id ��� ����������� kks
function Insert(ClientId:integer;GetID:integer;KKS:Pchar;XX:integer;YY:integer):integer;cdecl;
begin
  if(isOpenConnection) then
    begin
    //���������� � ������
    detectorList[lendetectorList-1].localId:=lendetectorList;
    detectorList[lendetectorList-1].KKS:=KKS;

    //���������� ����������� �������
    inc(lendetectorList);
    SetLength(detectorList,lendetectorList);
    Insert:=lendetectorList-1;
    end
    else
    begin
      ShowMessage('���������� �� ������������');
      Insert:=-1;
    end;

end;

//�������� id ������� ��� ���� ��������
procedure Subscribe(ClientID,GetID:integer); cdecl;
var
  i,position:integer;
  countGet:integer;
  sendStr,getStr:string;
begin
    logger.Debug('start Subscribe');
   //���� ���������� �����������
   if(clientSocket.Active) then
   begin
      //��������� �� kks ��� ��������� serverId
      sendStr:='1'+IntToStr(lenDetectorList-1)+#9;

      //��������� ��� kks ��������
      for i:=0 to lenDetectorList-1 do
         sendStr:=sendStr+detectorList[i].KKS+#9;

      logger.Debug('send string - ' + sendStr);

      //���������� ������ �� ������
      clientSocket.Socket.SendText(sendStr);
      Sleep(500);

      //�������� ������ � servId
      getStr:= clientSocket.Socket.ReceiveText;

      //���������� ������
      logger.Debug('params - ' + getstr+ ' length -' + IntToStr(Length(getStr)));

      if(Length(getStr)>0) then
      begin
        //��������� ���������� ���������� �������
        countGet:=StrToInt(Copy(getStr,1,Pos(#9,getStr)-1));
        getStr:= Copy(getStr,Pos(#9,getStr)+1,Length(getStr)- Pos(#9,getStr));
        if(countGet<>0) then
        begin
          //��������� ��� id
          i:=0;
          //������ � ������������ ��������� id � id �������
          while((Length(getStr)>0) and (i<countGet)) do
          begin
            position:= Pos(#9,getStr);
            //�������� ���� id �� ������ � ��������� ��� � ������
            detectorList[i].serverId:= StrToInt(Copy(getStr,1,position-1));
            //������� �� ������ ��� id
            getStr:= Copy(getStr,position+1,Length(getStr)-position);
            //logger.Debug('id = ' + IntToStr(detectorList[i].localId)+ ' serverid = ' +IntToStr(detectorList[i].serverId) );
            inc(i);
          end;
          if(i<countGet) then ShowMessage('�������� �� ��� id �������');
        end
          else
              ShowMessage('������ ��� ��������� id � �������');
      end
       else
    begin
      ShowMessage('���������� �� ������������');
    end;
    end;
    logger.Debug('close Subscribe');
end;

//���������� ������ ������
function GetChannelStatus(ClientID,GetID:integer):integer;cdecl;
begin
  GetChannelStatus:=$02;
end;

procedure CopyLayer(ClientID,GetID:integer);cdecl;
var
  i,index,position,getCount:integer;
  getStr,detectorStr,valueStr:string;
  valD:double;
  valI:integer;
begin
logger.Debug('start CopyLayer');
   //���� ���������� �����������
   if(isOpenConnection) then
   begin
     //��������� ������ �� ������
     clientSocket.Socket.SendText('2');
     Sleep(20);
     getStr:='';
     //�������� ��� �������� ����������
     while(clientSocket.Socket.ReceiveLength>0) do
     getStr:=getstr+clientSocket.Socket.ReceiveText;
     logger.Debug('CopyLayer = ' + getStr);
     //�������� ���������� ����������
     position:= Pos(#9,getStr);
     getCount:= StrToInt(Copy(getStr,1,position-1));
     logger.Debug('Count = ' + IntToStr(getCount));
     getStr:= Copy(getStr,position+1,Length(getStr)-position);

     //�������� ��� ���������
     i:=0;
     while((i<getCount) and(Length(getStr)>1)) do
     begin
       //�������� �������� ������ �������
       position:=Pos(#9,getStr);
       if(position>1) then
       begin
        detectorStr:=Copy(getStr,1,position-1);
        //logger.Debug(detectorStr);
        //������� ��� ���������
        getStr:=Copy(getStr,position+1,Length(getStr)-position);
        
        //�������� ������ ���� "id value status"
        //������� �� ��� ��� ��������

        //������� id
        position:= Pos(' ',detectorStr);
        valueStr:= Copy(detectorStr,1,position-1);
        //logger.Debug('id - ' + valueStr);

        //������� �� ������
        detectorStr:= Copy(detectorStr,position+1, Length(detectorStr)-position);
        valI:=StrToInt(valueStr);
        //�������� index �� serverId
        index := findIndexByServerID(valI);

        //�������� value �� ������
        position:= Pos(' ',detectorStr);
        valueStr:= Copy(detectorStr,1,position-1);
        //logger.Debug('value - ' + valueStr);

        //������� �� ������
        detectorStr:= Copy(detectorStr,position+1, Length(detectorStr)-position);
        valD:=StrToFloat(valueStr);
        detectorList[index].value:=valD;

        //�������� status �� ������
        valueStr:= detectorStr;
        //logger.Debug('status - ' + valueStr);
        valI:=StrToInt(valueStr);
        detectorList[index].status:=valI;

       end
        else getStr:='';
        inc(i);
     end;

   end
       else
    begin
      ShowMessage('���������� �� ������������');
    end;
        logger.Debug('close CopyLayer');
end;


//���������� �������� ��������� �� ��� Id, ���� id �� �������, �� ���������� -1
function GetFloat(ClientId,GetId,index:integer): real; cdecl;
var
  i:integer;
begin
  //logger.Debug('open GetFloat');
  //���� ���������� �����������
   if(isOpenConnection) then
   begin
     i:=findIndexByLocalID(index);
     //logger.Debug('find index - ' + IntToStr(i));
     if i>-1 then
      GetFloat:= detectorList[i].value
     else GetFloat:=-1;
   end
       else
    begin
      ShowMessage('���������� �� ������������');
      GetFloat:= -1;
    end;
    //logger.Debug('close GetFloat');
end;

//���������� ������ ��������� �� ��� Id, ���� id �� �������, �� ���������� -1
function GetStatus( ClientID:integer; ChannelID:integer;ParamID:integer):integer;cdecl;
var
  i:integer;
begin
    //logger.Debug('open GetStatus');
  //���� ���������� �����������
   if(isOpenConnection) then
   begin
      i:=findIndexByLocalID(ParamID);
      //logger.Debug('find index - ' + IntToStr(i));
      if i>-1 then
      GetStatus:=detectorList[i].status
      else GetStatus:=7;
   end
       else
    begin
      ShowMessage('���������� �� ������������');
      GetStatus:=7;
    end;
    //logger.Debug('close GetStatus');
end;

// ��������� ������ � ������ �����������
procedure Unsubscribe(ClientId,GetId:integer); cdecl;
begin
  //���� ���������� �����������
   if(isOpenConnection) then
   begin
     clientSocket.Close;
     isOpenConnection:=false;
   end
       else
    begin
      ShowMessage('���������� �� ������������');
    end;
end;

procedure ShutdownModLib(clientId:integer);  cdecl;
begin

end;

exports
 CreateChannel,
 Insert,
 Subscribe,
 GetChannelStatus,
 CopyLayer,
 GetFloat,
 Unsubscribe,
 InitModLib,
 ShutdownModLib,
 GetStatus;




begin

end.

