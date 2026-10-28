unit C4D.MaskEdit;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Mask;

type
  TC4DMaskEdit = class(TCustomMaskEdit)
  private
    FDisplayFormat: string;
    FDecimalPlaces: Cardinal;
    FDecimalPlacesAlwaysShown: Boolean;
    FZeroEmpty: Boolean;
    FValue: Extended;
    FMinValue: Extended;
    FMaxValue: Extended;
    FDecimalPlaceRound: Boolean;
    FCheckOnExit: Boolean;
    FFocused: Boolean;
    FFormatting: Boolean;
    FFormatOnEditing: Boolean;
    FLiberarWMPaint: Boolean;
    FVersion: string;
    function GetDisplayFormat: string;
    procedure SetDisplayFormat(const Value: string);
    procedure DataChanged;
    function GetEditFormat: String;
    function GetValue: Extended;
    procedure SetValue(AValue: Extended);
    procedure UpdateData;
    function ChecarMinMaxValue(ANewValue: Extended; ARaiseOnError: Boolean): Extended;
    procedure ChegarValoresMinMaxSeConf;
    procedure SetFocused(Value: Boolean);
    procedure SetFormatOnEditing(const Value: Boolean);
    procedure ReformatEditText;
    procedure SetDecimalPlaces(const Value: Cardinal);
    procedure SetDecimalPlacesAlwaysShown(const Value: Boolean);
    function IsFormatStored: Boolean;
    procedure SetMaxValue(const AValue: Extended);
    procedure SetMinValue(const AValue: Extended);
    procedure SetZeroEmpty(const Value: Boolean);
    procedure SetDecimalPlaceRound(const Value: Boolean);
    function IsValidChar(Key: Char): Boolean;
    function GetText: string;
    procedure SetText(const AValue: string);
    procedure CMEnter(var Msg: TCMEnter); message CM_ENTER;
    procedure CMExit(var Msg: TCMExit); message CM_EXIT;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMPaste(var Msg: TMessage); message WM_PASTE;
  protected
    function FormatDisplayText(Value: Extended): string;
    function GetDisplayText: string; virtual;
    procedure Change; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    property Formatting: Boolean read FFormatting;
    procedure KeyPress(var Key: Char); override;
    property Text: string read GetText write SetText stored False;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DisplayText: string read GetDisplayText;
    procedure Clear; override;
  published
    property Version: string read FVersion stored False;
    property DisplayFormat: string read GetDisplayFormat write SetDisplayFormat stored IsFormatStored;
    property Value: Extended read GetValue write SetValue;
    property DecimalPlaces: Cardinal read FDecimalPlaces write SetDecimalPlaces;
    property CheckOnExit: Boolean read FCheckOnExit write FCheckOnExit;
    property FormatOnEditing: Boolean read FFormatOnEditing write SetFormatOnEditing;
    property MaxValue: Extended read FMaxValue write SetMaxValue;
    property MinValue: Extended read FMinValue write SetMinValue;
    property ZeroEmpty: Boolean read FZeroEmpty write SetZeroEmpty;
    property DecimalPlaceRound: Boolean read FDecimalPlaceRound write SetDecimalPlaceRound;
    property DecimalPlacesAlwaysShown: Boolean read FDecimalPlacesAlwaysShown write SetDecimalPlacesAlwaysShown;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BiDiMode;
    property DragCursor;
    property DragKind;
    property ParentBiDiMode;
    property ImeMode;
    property ImeName;
    property OnEndDock;
    property OnStartDock;
    property Action;
    property Align;
    property Alignment;
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property Color;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property Anchors;
    property Constraints;
    property MaxLength;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnContextPopup;
    property OnStartDrag;
    property Touch;
    property TextHint;
  end;

procedure Register;

implementation

//{..$R *.RES}

uses
  C4D.MaskEdit.Consts,
  C4D.MaskEdit.Utils;

procedure Register;
begin
  RegisterComponents('C4D', [TC4DMaskEdit]);
end;

constructor TC4DMaskEdit.Create;
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption];
  FLiberarWMPaint := True;
  FVersion := TC4DMaskEditConsts.Version;
  FDisplayFormat := TC4DMaskEditConsts.DEFAULT_DISPLAY_FORMAT;
  FDecimalPlaces := 2;
  FDecimalPlacesAlwaysShown := True; //False
  FZeroEmpty := True;
  FFormatOnEditing := True;
  FMinValue := 0;
  FMaxValue := 0;
  FDecimalPlaceRound := False;
  FFocused := False;
  FFormatting := False;
  FCheckOnExit := False;

  inherited Text := '';
  inherited Alignment := taLeftJustify;
  Self.DataChanged;
  ControlState := ControlState - [csCreating];
end;

destructor TC4DMaskEdit.Destroy;
begin
  inherited Destroy;
end;

function TC4DMaskEdit.GetDisplayFormat: string;
begin
  Result := FDisplayFormat;
end;

procedure TC4DMaskEdit.SetDecimalPlaceRound(const Value: Boolean);
begin
  if FDecimalPlaceRound <> Value then
  begin
    FDecimalPlaceRound := Value;
    SetValue(Self.ChecarMinMaxValue(FValue, False));
    Invalidate;
    Self.ReformatEditText;
  end;
end;

procedure TC4DMaskEdit.SetDecimalPlaces(const Value: Cardinal);
begin
  if FDecimalPlaces <> Value then
  begin
    FDecimalPlaces := Value;
    Self.SetDisplayFormat(GetEditFormat);
    Self.SetValue(Self.ChecarMinMaxValue(FValue, False));
    Self.DataChanged;
    Invalidate;
  end;
end;

procedure TC4DMaskEdit.SetDecimalPlacesAlwaysShown(const Value: Boolean);
begin
  if FDecimalPlacesAlwaysShown <> Value then
  begin
    FDecimalPlacesAlwaysShown := Value;
    Self.SetDisplayFormat(GetEditFormat);
    Self.SetValue(Self.ChecarMinMaxValue(FValue, False));
    Self.DataChanged;
    Invalidate;
  end;
end;

procedure TC4DMaskEdit.SetDisplayFormat(const Value: string);
begin
  if DisplayFormat <> Value then
  begin
    FDisplayFormat := Value;
    Invalidate;
    Self.DataChanged;
  end;
end;

function TC4DMaskEdit.FormatDisplayText(Value: Extended): string;
begin
  if DisplayFormat <> '' then
    Result := FormatFloat(DisplayFormat, Value)
  else
    Result := FloatToStr(Value);
end;

function TC4DMaskEdit.GetDisplayText: string;
begin
  Result := FormatDisplayText(FValue);
end;

function TC4DMaskEdit.GetEditFormat: string;
begin
  if(FDecimalPlaces = 0)then
    Result := '0'
  else
  begin
    Result := ',0';
    if FDecimalPlacesAlwaysShown then
      Result := Result + '.' + TC4DMaskEditUtils.MakeStr('0', FDecimalPlaces)
    else
      Result := Result + '.' + TC4DMaskEditUtils.MakeStr('#', FDecimalPlaces);
  end;
//  Result := '0';
//  if FDecimalPlaces > 0 then
//    Result := Result + '.' + MakeStr('#', FDecimalPlaces);
end;

procedure TC4DMaskEdit.Change;
begin
  if not FFormatting then
  begin
    if FFormatOnEditing and FFocused then
      Self.ReformatEditText;
    inherited Change;
  end;
end;

function TC4DMaskEdit.ChecarMinMaxValue(ANewValue: Extended; ARaiseOnError: Boolean): Extended; //CheckValue
var
  LDecimalPlace: Integer;
begin
  if FDecimalPlaceRound then
  begin
    LDecimalPlace := FDecimalPlaces;
    ANewValue := Int(ANewValue * Exp(LDecimalPlace * Ln(10)) + Sign(ANewValue) * 0.50000001) * Exp(-LDecimalPlace * Ln(10));
  end;
  Result := ANewValue;
  if FMaxValue <> FMinValue then
  begin
    if FMaxValue > FMinValue then
    begin
      if ANewValue < FMinValue then
        Result := FMinValue
      else
      if ANewValue > FMaxValue then
        Result := FMaxValue;
    end
    else
    begin
      if FMaxValue = 0 then
      begin
        if ANewValue < FMinValue then
          Result := FMinValue;
      end
      else
      if FMinValue = 0 then
      begin
        if ANewValue > FMaxValue then
          Result := FMaxValue;
      end;
    end;

    if ARaiseOnError and (Result <> ANewValue) then
      raise Exception.Create(Format('O valor deve estar entre %.*f e %.*f', [FDecimalPlaces, FMinValue, FDecimalPlaces, FMaxValue]));
  end;
end;

procedure TC4DMaskEdit.UpdateData;
var
  LValueString: string;
  LValueExtended: Extended;
begin
  ValidateEdit;
  LValueString := TC4DMaskEditUtils.TextToValText(EditText);
  LValueExtended := StrToFloatDef(LValueString, 0); //AQUI
  FValue := Self.ChecarMinMaxValue(LValueExtended, False);
end;

function TC4DMaskEdit.GetValue: Extended;
begin
  if not (csDesigning in ComponentState) then
  begin
    try
      Self.UpdateData;
    except
      FValue := FMinValue;
    end;
  end;
  Result := FValue;
end;

function TC4DMaskEdit.IsFormatStored: Boolean;
begin
  Result := True; //(DisplayFormat <> TC4DMaskEditConsts.DEFAULT_DISPLAY_FORMAT);
end;

function TC4DMaskEdit.IsValidChar(Key: Char): Boolean;
var
  LStr: string;
  LSelStart: Integer;
  LSelStop: Integer;
  LecPos: Integer;
  LRetValue: Extended;
begin
  Result := False;
  LStr := EditText;
  GetSel(LSelStart, LSelStop);
  System.Delete(LStr, LSelStart + 1, LSelStop - LSelStart);
  System.Insert(Key, LStr, LSelStart + 1);
  LStr := TC4DMaskEditUtils.TextToValText(LStr);
  LecPos := Pos(FormatSettings.DecimalSeparator, LStr);
  if (LecPos > 0) then
  begin
    LSelStart := Pos('E', UpperCase(LStr));
    if (LSelStart > LecPos) then
      LecPos := LSelStart - LecPos
    else
      LecPos := Length(LStr) - LecPos;
    if LecPos > Integer(FDecimalPlaces) then
      Exit;
  end;
  Result := TC4DMaskEditUtils.IsValidFloat(LStr, LRetValue);
  if Result and (FMinValue >= 0) and (FMaxValue > 0) and (LRetValue < 0) then
    Result := False;
end;

procedure TC4DMaskEdit.KeyPress(var Key: Char);
begin
  if CharInSet(Key, ['.', ','] - [FormatSettings.ThousandSeparator]) then
    Key := FormatSettings.DecimalSeparator;

  inherited KeyPress(Key);

  if CharInSet(Key, [#32..#255]) and not IsValidChar(Key) then
  begin
    Key := #0;
  end
  else if Key = #27 then
  begin
    Reset;
    Key := #0;
  end;
end;

procedure TC4DMaskEdit.SetValue(AValue: Extended);
begin
  FValue := Self.ChecarMinMaxValue(AValue, False);
  Self.DataChanged;
  Invalidate;
end;

procedure TC4DMaskEdit.SetZeroEmpty(const Value: Boolean);
begin
  if FZeroEmpty <> Value then
  begin
    FZeroEmpty := Value;
    DataChanged;
  end;
end;

procedure TC4DMaskEdit.DataChanged;
var
  LEditFormat: string;
  LFoiModificado: Boolean;
begin
  LEditFormat := GetEditFormat;
  { Changing EditText sets Modified to false }
  LFoiModificado := Modified;
  try
    if (FValue = 0.0) and FZeroEmpty then
      EditText := ''
    else
      EditText := FormatFloat(LEditFormat, Self.ChecarMinMaxValue(FValue, False));
  finally
    Modified := LFoiModificado;
  end;
end;

procedure TC4DMaskEdit.ChegarValoresMinMaxSeConf; //CheckRange
begin
  if not(csDesigning in ComponentState)and FCheckOnExit then
    Self.ChecarMinMaxValue(StrToFloat(TC4DMaskEditUtils.TextToValText(EditText)), True);
end;

procedure TC4DMaskEdit.Clear;
begin
  inherited;
  Text := '';
  FValue := 0;
end;

procedure TC4DMaskEdit.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then
  begin
    FFocused := Value;
    Invalidate;
    FFormatting := True;
    try
      Self.DataChanged;
    finally
      FFormatting := False;
    end;
  end;
end;

procedure TC4DMaskEdit.ReformatEditText;
var
  LStr: string;
  LIsEmpty: Boolean;
  LOldLen: Integer;
  LSelStart: Integer;
  LSelStop: Integer;
  LWasModified: Boolean;
begin
  FFormatting := True;
  LWasModified := Modified;
  try
    LStr := inherited Text;
    LOldLen := Length(LStr);
    LIsEmpty := (LOldLen = 0) or (LStr = '-');
    if HandleAllocated then
      GetSel(LSelStart, LSelStop);
    if not LIsEmpty then
      LStr := TC4DMaskEditUtils.TextToValText(LStr);
    LStr := TC4DMaskEditUtils.FormatFloatStr(LStr, Pos(',', DisplayFormat) > 0);
    inherited Text := LStr;
    if HandleAllocated and (GetFocus = Handle) and
      not (csDesigning in ComponentState)
    then
    begin
      Inc(LSelStart, Length(LStr) - LOldLen);
      SetCursor(LSelStart);
    end;
  finally
    FFormatting := False;
    Modified := LWasModified;
  end;
end;
procedure TC4DMaskEdit.SetFormatOnEditing(const Value: Boolean);
begin
  if FFormatOnEditing <> Value then
  begin
    FFormatOnEditing := Value;
    if FFormatOnEditing then
      inherited Alignment := Alignment
    else
      inherited Alignment := taLeftJustify;
    if FFormatOnEditing and FFocused then
      Self.ReformatEditText
    else
    if FFocused then
    begin
      Self.UpdateData;
      Self.DataChanged;
    end;
  end;
end;

procedure TC4DMaskEdit.SetMaxValue(const AValue: Extended);
begin
  if FMaxValue <> AValue then
  begin
    FMaxValue := AValue;
    Value := FValue;
  end;
end;

procedure TC4DMaskEdit.SetMinValue(const AValue: Extended);
begin
  if FMinValue <> AValue then
  begin
    FMinValue := AValue;
    Value := FValue;
  end;
end;

function TC4DMaskEdit.GetText: string;
begin
   Result := inherited Text;
end;

procedure TC4DMaskEdit.SetText(const AValue: string);
begin
  if not (csReading in ComponentState) then
  begin
    FValue := Self.ChecarMinMaxValue(StrToFloat(TC4DMaskEditUtils.TextToValText(AValue)), False);
    DataChanged;
    Invalidate;
  end;
end;

procedure TC4DMaskEdit.DoEnter;
const
  CM_JVBASE = CM_BASE + $0200;
  CM_FIXCARETPOSITION = CM_JVBASE + $007;
var
  LPt: TPoint;
begin
  SetFocused(True);
  if(FFormatOnEditing)then
    Self.ReformatEditText;

  inherited Text := FormatFloat('.' + TC4DMaskEditUtils.MakeStr('#', FDecimalPlaces), StrToFloatDef(TC4DMaskEditUtils.TextToValText(inherited Text), 0));

  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll
  else if IsMasked and (csLButtonDown in ControlState)and(GetWindowLong(Handle, GWL_STYLE)
  and ES_MULTILINE <> 0)
  then
  begin
    { ES_MULTILINE causes the edit to place the caret at the wrong location. }
    if GetCursorPos(LPt) then
    begin
      LPt := ScreenToClient(LPt);
      PostMessage(Handle, CM_FIXCARETPOSITION, 0, MakeLong(Word(LPt.X), Word(LPt.Y)));
    end;
  end;

  inherited DoEnter;
end;

procedure TC4DMaskEdit.DoExit;
begin
  try
    Self.ChegarValoresMinMaxSeConf;
    Self.UpdateData;
  except
    SelectAll;
    if(CanFocus)then
      SetFocus;
    raise;
  end;
  SetFocused(False);
  SetCursor(0);
  inherited DoExit;
  EditText := Self.GetDisplayText;
end;

procedure TC4DMaskEdit.CMEnter(var Msg: TCMEnter);
begin
  FLiberarWMPaint := False;
  inherited;
end;

procedure TC4DMaskEdit.CMExit(var Msg: TCMExit);
begin
   Self.DoExit;
end;

procedure TC4DMaskEdit.WMPaint(var Msg: TWMPaint);
begin
  inherited;
  if(FLiberarWMPaint)then
    EditText := Self.GetDisplayText;
end;

procedure TC4DMaskEdit.WMPaste(var Msg: TMessage);
var
  LStr: string;
  LWasModified: Boolean;
begin
  LWasModified := Modified;
  LStr := EditText;
  try
    inherited;
    Self.UpdateData;
  except
    EditText := LStr;
    Modified := LWasModified;
    SelectAll;
    if CanFocus then
      SetFocus;
  end;
end;

end.
