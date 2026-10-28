unit C4D.MaskEdit.Utils;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows;

type
  TC4DMaskEditUtils = class
  private
    class function RemoverEspacoEmBranco(AValue: string): string;
    class function DelChars(const S: string; Chr: Char): string;
    class function ReplaceStr(const S, Srch, Replace: string): string;
  public
    class function FormatFloatStr(const S: string; Thousands: Boolean): string;
    class function MakeStr(C: WideChar; N: Integer): WideString;
    class procedure FillWideChar(var Buffer; Count: Integer; const Value: WideChar);
    class function TextToValText(const AValue: string): string;
    class function IsValidFloat(const Value: string; var RetValue: Extended): Boolean;
    class function RemoveLetters(const Value: string): string;
  end;

implementation

uses
  C4D.MaskEdit.Consts;

class function TC4DMaskEditUtils.FormatFloatStr(const S: string; Thousands: Boolean): string;
var
  I, MaxSym, MinSym, Group: Integer;
  IsSign: Boolean;
begin
  Result := '';
  MaxSym := Length(S);
  IsSign := (MaxSym > 0) and CharInSet(S[1], ['+', '-']);
  if IsSign then
    MinSym := 2
  else
    MinSym := 1;
  I := Pos(TC4DMaskEditConsts.DECIMAL_SEPARATOR, S);
  if I > 0 then
    MaxSym := I - 1;
  I := Pos('E', AnsiUpperCase(S));
  if I > 0 then
    MaxSym := Min(I - 1, MaxSym);
  Result := Copy(S, MaxSym + 1, MaxInt);
  Group := 0;
  for I := MaxSym downto MinSym do
  begin
    Result := S[I] + Result;
    Inc(Group);
    if (Group = 3) and Thousands and (I > MinSym) then
    begin
      Group := 0;
      Result := TC4DMaskEditConsts.MILHAR_SEPARATOR + Result;
    end;
  end;
  if IsSign then
    Result := S[1] + Result;
end;

class function TC4DMaskEditUtils.MakeStr(C: WideChar; N: Integer): WideString;
begin
  if N < 1 then
    Result := ''
  else
  begin
    SetLength(Result, N);
    Self.FillWideChar(Result[1], Length(Result), C);
  end;
end;

class procedure TC4DMaskEditUtils.FillWideChar(var Buffer; Count: Integer; const Value: WideChar);
var
  P: PLongint;
  Value2: Cardinal;
  CopyWord: Boolean;
begin
  Value2 := (Cardinal(Value) shl 16) or Cardinal(Value);
  CopyWord := Count and $1 <> 0;
  Count := Count div 2;
  P := @Buffer;
  while Count > 0 do
  begin
    P^ := Value2;
    Inc(P);
    Dec(Count);
  end;
  if CopyWord then
    PWideChar(P)^ := Value;
end;

class function TC4DMaskEditUtils.RemoverEspacoEmBranco(AValue: string): string;
begin
   Result := StringReplace(Avalue.Trim, ' ', '', [rfReplaceAll, rfIgnoreCase]);
end;

class function TC4DMaskEditUtils.DelChars(const S: string; Chr: Char): string;
var
  I: Integer;
begin
  Result := S;
  for I := Length(Result) downto 1 do
  begin
    if Result[I] = Chr then
      Delete(Result, I, 1);
  end;
end;

class function TC4DMaskEditUtils.ReplaceStr(const S, Srch, Replace: string): string;
var
  I: Integer;
  Source: string;
begin
  Source := S;
  Result := '';
  repeat
    I := Pos(Srch, Source);
    if I > 0 then
    begin
      Result := Result + Copy(Source, 1, I - 1) + Replace;
      Source := Copy(Source, I + Length(Srch), MaxInt);
    end
    else
      Result := Result + Source;
  until I <= 0;
end;

class function TC4DMaskEditUtils.RemoveLetters(const Value: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Value.Length do
    if(CharInSet(Value[i], ['0'..'9', '-', ',', '.']))then
      Result := Result + Value[i];
end;

class function TC4DMaskEditUtils.TextToValText(const AValue: string): string;
begin
  Result := RemoverEspacoEmBranco(AValue);
  if TC4DMaskEditConsts.DECIMAL_SEPARATOR <> FormatSettings.ThousandSeparator then
    Result := DelChars(Result, FormatSettings.ThousandSeparator);

  if(TC4DMaskEditConsts.DECIMAL_SEPARATOR <> '.') and (FormatSettings.ThousandSeparator <> '.')then
    Result := ReplaceStr(Result, '.', TC4DMaskEditConsts.DECIMAL_SEPARATOR);

  if(TC4DMaskEditConsts.DECIMAL_SEPARATOR <> ',') and (FormatSettings.ThousandSeparator <> ',')then
    Result := ReplaceStr(Result, ',', TC4DMaskEditConsts.DECIMAL_SEPARATOR);

  Result := RemoveLetters(Result);

  if Result = '' then
    Result := '0'
  else if Result = '-' then
    Result := '-0';
end;

class function TC4DMaskEditUtils.IsValidFloat(const Value: string; var RetValue: Extended): Boolean;
var
  I: Integer;
  Buffer: array[0..63] of Char;
begin
  Result := False;
  for I := 1 to Length(Value) do
    if not CharInSet(Value[I], [FormatSettings.DecimalSeparator, '-', '+', '0'..'9', 'e', 'E']) then
      Exit;
  Result := TextToFloat(StrPLCopy(Buffer, Value,
    SizeOf(Buffer) - 1), RetValue); //{$IFNDEF VER80}, fvExtended{$ENDIF}
end;

end.
