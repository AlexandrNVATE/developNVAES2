unit uStringOperation;

interface

uses Classes,SysUtils;

function GetFirstSubStr(var SubStr,InputStr:string;Delimiter:char):boolean;
function TranslateToValidNumber(InputStr:string):String;
function TranslateToValidDate(InputStr:string):String;

function AlreadyExist(NewItems:string;Destination:TStrings):boolean;
function NumberToStr(IntNumber:integer):string;
function Number3XToStr(IntNumber:integer):string;

procedure WriteStrToFile(FileHandle:integer;Str1024:string);
procedure WriteFloatToFile(FileHandle:integer;Value:double);
procedure WriteBoolToFile(FileHandle:integer;Value:boolean);
function ReadStrFromFile(FileHandle:integer):string;
function ReadFloatFromFile(FileHandle:integer):double;
function SetComMask(ParamList: TStrings):string;
function EvenStr(Str:string;Width:integer):string;
function DelSpacers(InputStr:string;var OutStr:string;Spacer:char):boolean;
function DateToStrYYMMDD(DateTime:TDateTime):string;

implementation

function GetFirstSubStr(var SubStr,InputStr:string;Delimiter:char):boolean;
var TempStr:string;
    PosSpl:integer;
begin
if (Length(InputStr)>=1) then Result:=True else Result:=False;
if Result then
 begin
  PosSpl:=Pos(Delimiter,InputStr);
  if (PosSpl=0) and (Delimiter=#9) then
  PosSpl:=length(InputStr)+1;
  if PosSpl = 0 then begin Result:=False; exit; end;
  SubStr:=Copy(InputStr,1,PosSpl-1);
  SetLength(TempStr,Length(InputStr));
  TempStr:=InputStr;
  SetLength(InputStr,Length(TempStr)-PosSpl);
  InputStr:=Copy(TempStr,PosSpl+1,Length(InputStr));
 end;

end;

function TranslateToValidNumber(InputStr:string):String;
var i:integer;
  begin
   Result:='';
   for i:=1 to Length(InputStr) do
     if (ord(InputStr[i])>43) and (ord(InputStr[i])< 70) then Result:=Result+InputStr[i];
  end;

function TranslateToValidDate(InputStr:string):String;
var i:integer;
  begin
   Result:='';
   for i:=1 to Length(InputStr) do
     if (InputStr[i]=',') then Result:=Result+'.'
     else Result:=Result+InputStr[i];
  end;

function AlreadyExist(NewItems:string;Destination:TStrings):boolean;
var i:integer;
begin
Result:=False;
 for i:=0 to Destination.Count-1 do
  if Destination[i] = NewItems then result:=True; 
end;

// ������� ��� ������������ ������ �� 2-� ����������������
function NumberToStr(IntNumber:integer):string;
begin
if IntNumber<10 then Result:='0'+IntToStr(IntNumber) else
Result:=inttostr(IntNumber);
end;

procedure  WriteStrToFile(FileHandle:integer;Str1024:string);
var i,StrL:integer;
  C:array [0..1023] of Char;
begin 
 StrL:=Length(Str1024);
 for i:=0 to StrL-1 do
 C[i]:=Str1024[i+1];
 FileWrite(FileHandle,StrL,sizeof(StrL));
 FileWrite(FileHandle,C,StrL);
end;

procedure WriteFloatToFile(FileHandle:integer;Value:double);
begin
 FileWrite(FileHandle,Value,Sizeof(Value));
end;

function ReadStrFromFile(FileHandle:integer):string;
var i,StrL:integer;
  C:array [0..1023] of Char;
begin
    FileRead(FileHandle,StrL,sizeof(StrL));

    FileRead(FileHandle,C,StrL);
    SetLength(Result,StrL);

    for i:=0 to StrL-1 do
    Result[i+1]:=C[i];
end;

function ReadFloatFromFile(FileHandle:integer):double;
begin
 FileRead(FileHandle,Result,SizeOf(Result));
end;

function SetComMask(ParamList: TStrings):string;
var TempStr:string;
   i,j,CountChars:integer;
begin
Result:='';
 if ParamList.Count>0 then
 begin
  CountChars:=Length(ParamList.Strings[0]);
  for i:=1 to ParamList.Count-1 do
  if Length(ParamList.Strings[i])<>CountChars then Exit;
  SetLength(TempStr,CountChars);
  for i:=1 to CountChars do  // for all char in strings
  begin
    TempStr[i]:=ParamList.Strings[0][i];
    for j:=1 to ParamList.Count-1 do
     if ParamList.Strings[j][i]<>TempStr[i] then TempStr[i]:='?';
  end;
end;
Result:=TempStr;
end;

function Number3XToStr(IntNumber:integer):string;
begin
Result:='';
 if IntNumber <100 then Result:='0';
 if IntNumber<10 then Result:=Result+'0';

Result:=Result+ IntToStr(IntNumber);

end;

function EvenStr(Str:string;Width:integer):string;
var i:integer;
begin
 Result:=Str;
 if Length(str)<Width then
  for i:=Length(str) to Width do
 begin
  Result:=Result+#32;
 end;
end;

function DelSpacers(InputStr:string;var OutStr:string;Spacer:char):boolean;
var TempStr:string;
    i:integer;
begin
if (Length(InputStr)>=1) then Result:=True else Result:=False;
if Result then
 begin
  i:=1;
  while (inputStr[i]=spacer )do
    inc(i);
  if i<Length(InputStr) then
  OutStr:=copy(InputStr,i,Length(InputStr)-i);
 end;
end;

procedure WriteBoolToFile(FileHandle:integer;Value:boolean);
begin
 FileWrite(FileHandle,Value,Sizeof(Value));
end;
function DateToStrYYMMDD(DateTime:TDateTime):string;
var st:string;
begin;
 st:=DateToStr(DateTime);
 result:=copy(st,7,4)+copy(st,4,2)+copy(st,1,2);
end;
end.





