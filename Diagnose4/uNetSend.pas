unit uNetSend;
//------------------------------------------------------------------------------
//uNetSend - �������� ���������� ������ ����� ������
//16.07.2014 �����: ��������� �.�.
//------------------------------------------------------------------------------

interface

uses SysUtils,Dialogs,uStringOperation;

type TValue=record
  Value:double;
  DateTime:TDateTime;
  Status:byte; //0 - Ok, 1...n - unnormal
  end;
const Status_OK:byte=0;  // By default Status=0 -> Status_Ok;
const Status_Invalid:byte=1;  // 

type TValueArray= array of TValue;

const NilFEPValue:TValue=
(  Value:-1;
  DateTime:0;
  Status:0);

 type
 TSendData = class(TObject)
 private
   FCountIndexArray:integer;
   FIndexArray:array of integer;
   FCurData:TValueArray;
   FSendDataStr:string;
    FInitilized: boolean;
    procedure SetInitilized(const Value: boolean);
 protected

 public
   property SendStr:string read FSendDataStr;
   property Initilized:boolean read FInitilized ;
   procedure Clear;
   procedure AddNewIndex(Index:integer);
   procedure NewSendData(Data:TValueArray);
   procedure Initalize(Data:TValueArray);
   constructor Create;
   destructor Destroy;
 published

 end;
  function ValueToNetStr(Index:integer;Value:TValue):string;
  function NetStrToValue(NetStr:string;var Index:integer;var Value:TValue):boolean;
implementation

{ TSendData }

procedure TSendData.AddNewIndex(Index: integer);
begin
 SetLength(FIndexArray,FCountIndexArray+1);
 FIndexArray[FCountIndexArray]:=Index;
 Inc(FCountIndexArray);
end;

procedure TSendData.Clear;
begin
 FCountIndexArray:=0;
 SetLength(FIndexArray,0);
 SetLength(FCurData,0);
 FInitilized:=False;
 FSendDataStr:='';
end;

constructor TSendData.Create;
begin
 inherited Create;
 FCountIndexArray:=0;
 SetLength(FIndexArray,0);
 SetLength(FCurData,0);

 FInitilized:=False;
end;

destructor TSendData.Destroy;
begin
 SetLength(FIndexArray,0);
 SetLength(FCurData,0);
  inherited Destroy;
end;

procedure TSendData.NewSendData(Data: TValueArray);
var i,j,Count:integer;
begin
 Count:=Length(Data);
 FSendDataStr:='1';
 j:=0;
 for i:=0 to FCountIndexArray-1 do
   if (FCurData[i].Value<>Data[FIndexArray[i]].Value) or
      (FCurData[i].Status<>Data[FIndexArray[i]].Status)
   then
     begin
      FCurData[i]:=Data[FIndexArray[i]-1];
      FSendDataStr:=FSendDataStr+ValueToNetStr(FIndexArray[i],FCurData[i]);
     end;
end;

procedure TSendData.Initalize(Data: TValueArray);
var i:integer;
begin
 FSendDataStr:='1';
 for i:=0 to FCountIndexArray-1 do
 begin
  SetLength(FCurData,i+1);
  FCurData[i]:=Data[FIndexArray[i]];
  FSendDataStr:=FSendDataStr+ValueToNetStr(FIndexArray[i],FCurData[i]);
 end;
 FInitilized:=(FCountIndexArray>0);
end;

function ValueToNetStr(Index:integer;Value:TValue):string;
  begin
   Result:=#9+IntToStr(Index)+','+FloatToStr(Value.Value)+','+FloatToStr(Value.DateTime)+','+IntToStr(Value.Status);
  end;
procedure TSendData.SetInitilized(const Value: boolean);
begin
  FInitilized := Value;
end;
function NetStrToValue(NetStr:string;var Index:integer;var Value:TValue):boolean;
var substr:string;
 begin
 Result:=True;
  GetFirstSubStr(substr,NetStr,',');
  try
   if (substr<>'') or not(pos('.',substr)>0) then
   Index:=StrToInt(substr) else Index:=-1;
   GetFirstSubStr(substr,NetStr,',');
   try
    Value.Value:=StrToFloat(substr);
    GetFirstSubStr(substr,NetStr,',');
    try
     value.DateTime:=StrToFloat(substr);
      try
       if (NetStr<>'') or not(pos('.',NetStr)>0) or not(pos(',',NetStr)>0) then
       value.Status:=StrToInt(NetStr) else Value.Status:=1;
      except
        MessageDlg('������ ����������� ������� (����� �����) "'+NetStr+'" ��� ������������ ������� � ������� �� �������' ,mtInformation,[mbOk],0);
        Result:=False;
      end;
    except
      MessageDlg('������ ����������� ���� � ������� "'+substr+'" ��� ������������ ������� � ������� �� �������' ,mtInformation,[mbOk],0);
      Result:=False;
    end;
   except
     MessageDlg('������ ����������� ����� "'+substr+'" � ������������ ����� (��������) ��� ������������ ������� � ������� �� �������' ,mtInformation,[mbOk],0);
     Result:=False;
   end;
  except
     MessageDlg('������ ����������� ����� "'+substr+'" � ����� ����� (������) ��� ������������ ������� � ������� �� �������' ,mtInformation,[mbOk],0);
     Result:=False;
  end;
 end;
end.
