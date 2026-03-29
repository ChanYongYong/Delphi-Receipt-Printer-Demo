unit receiptTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Grids;

type
  TForm1 = class(TForm)
    Edit1: TEdit;              // Merchant name
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;              // Business registration number
    Label3: TLabel;
    Edit3: TEdit;              // Representative name
    Label4: TLabel;
    Edit4: TEdit;              // Phone number
    Label5: TLabel;
    Edit5: TEdit;              // Address
    Edit6: TEdit;              // Receipt title
    Label6: TLabel;
    Label7: TLabel;
    Edit7: TEdit;              // Receipt number
    Label8: TLabel;
    Edit8: TEdit;              // POS ID
    Label9: TLabel;
    Edit9: TEdit;              // Cashier name
    Label10: TLabel;
    Edit10: TEdit;             // Receipt copy type
    Label20: TLabel;
    StringGrid1: TStringGrid;  // Item list (grid)
    Label11: TLabel;
    Edit11: TEdit;             // Supply price
    Label12: TLabel;
    Edit12: TEdit;             // VAT
    Label13: TLabel;
    Edit13: TEdit;             // Payment method
    Label14: TLabel;
    Edit14: TEdit;             // Card company
    Label15: TLabel;
    Edit15: TEdit;             // Card number
    Label16: TLabel;
    Edit16: TEdit;             // Installment type
    Label17: TLabel;
    Edit17: TEdit;             // Approval number
    Label18: TLabel;
    Edit18: TEdit;             // Approved amount
    Label19: TLabel;
    Edit19: TEdit;             // Issued date/time
    Label21: TLabel;
    Edit20: TEdit;             // Printer name
    BtnPrint: TButton;         // Print receipt
    BtnSave: TButton;          // Save settings
    BtnAddRow: TButton;        // Add item row
    BtnDelRow: TButton;        // Delete item row
    BtnCalcAmount: TButton;    // Calculate amount
    procedure BtnPrintClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnAddRowClick(Sender: TObject);
    procedure BtnDelRowClick(Sender: TObject);
    procedure BtnCalcAmountClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure SaveSettings;
    procedure LoadSettings;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Printers, receipt, System.IniFiles;

// ============================================================
// BtnPrintClick — Collect form data and print receipt
// ============================================================

procedure TForm1.BtnPrintClick(Sender: TObject);
var
  Data: TReceiptData;
  i: Integer;
  OrderTotal: Integer;
  ItemLines: TStringList;
begin
  // Merchant info
  Data.MerchantName := Edit1.Text;
  Data.BusinessRegNumber := Edit2.Text;
  Data.RepresentativeName := Edit3.Text;
  Data.MerchantPhone := Edit4.Text;
  Data.MerchantAddress := Edit5.Text;

  // Ticket info
  Data.TicketTitle := Edit6.Text;
  Data.ReceiptNumber := Edit7.Text;
  Data.PosId := Edit8.Text;
  Data.CashierName := Edit9.Text;

  // Receipt copy type
  Data.ReceiptCopyType := Edit10.Text;

  // Build item list from StringGrid and parse via ParseItems
  ItemLines := TStringList.Create;
  try
    for i := 1 to StringGrid1.RowCount - 1 do
    begin
      if Trim(StringGrid1.Cells[0, i]) <> '' then
        ItemLines.Add(StringGrid1.Cells[0, i] + #9 + StringGrid1.Cells[1, i] +
          #9 + StringGrid1.Cells[2, i] + #9 + StringGrid1.Cells[3, i]);
    end;
    Data.Items := TReceiptPrinter.ParseItems(ItemLines);
  finally
    ItemLines.Free;
  end;

  // Calculate order total from items
  OrderTotal := 0;
  for i := 0 to Length(Data.Items) - 1 do
    OrderTotal := OrderTotal + Data.Items[i].Amount;

  // Totals
  Data.Totals.SupplyPrice := StrToIntDef(Edit11.Text, 0);
  Data.Totals.Vat := StrToIntDef(Edit12.Text, 0);
  Data.Totals.OrderTotal := OrderTotal;
  Data.Totals.TotalAmount := Data.Totals.SupplyPrice + Data.Totals.Vat;

  // Payment info
  Data.Payment.PaymentMethod := Edit13.Text;
  Data.Payment.CardCompany := Edit14.Text;
  Data.Payment.CardNumber := Edit15.Text;
  Data.Payment.InstallmentType := Edit16.Text;
  Data.Payment.ApprovalNumber := Edit17.Text;
  Data.Payment.ApprovedAmount := StrToIntDef(Edit18.Text, 0);

  // Issued date/time
  Data.IssuedAt := Edit19.Text;

  // Print receipt using the printer name from Edit20
  TReceiptPrinter.PrintReceipt(Edit20.Text, Data);
end;

// ============================================================
// FormCreate — Initialize StringGrid headers and load settings
// ============================================================

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Set StringGrid column headers
  StringGrid1.Cells[0, 0] := '품명';
  StringGrid1.Cells[1, 0] := '단가';
  StringGrid1.Cells[2, 0] := '수량';
  StringGrid1.Cells[3, 0] := '금액';

  // Set column widths
  StringGrid1.ColWidths[0] := 120;
  StringGrid1.ColWidths[1] := 70;
  StringGrid1.ColWidths[2] := 50;
  StringGrid1.ColWidths[3] := 80;

  // Load saved settings from INI file
  LoadSettings;
end;

// ============================================================
// SaveSettings — Save all field values and items to INI file
// ============================================================

procedure TForm1.SaveSettings;
var
  Ini: TIniFile;
  i: Integer;
begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) +
    'receiptTest.ini');
  try
    // Save Edit fields
    Ini.WriteString('Fields', 'Edit1', Edit1.Text);
    Ini.WriteString('Fields', 'Edit2', Edit2.Text);
    Ini.WriteString('Fields', 'Edit3', Edit3.Text);
    Ini.WriteString('Fields', 'Edit4', Edit4.Text);
    Ini.WriteString('Fields', 'Edit5', Edit5.Text);
    Ini.WriteString('Fields', 'Edit6', Edit6.Text);
    Ini.WriteString('Fields', 'Edit7', Edit7.Text);
    Ini.WriteString('Fields', 'Edit8', Edit8.Text);
    Ini.WriteString('Fields', 'Edit9', Edit9.Text);
    Ini.WriteString('Fields', 'Edit10', Edit10.Text);
    Ini.WriteString('Fields', 'Edit11', Edit11.Text);
    Ini.WriteString('Fields', 'Edit12', Edit12.Text);
    Ini.WriteString('Fields', 'Edit13', Edit13.Text);
    Ini.WriteString('Fields', 'Edit14', Edit14.Text);
    Ini.WriteString('Fields', 'Edit15', Edit15.Text);
    Ini.WriteString('Fields', 'Edit16', Edit16.Text);
    Ini.WriteString('Fields', 'Edit17', Edit17.Text);
    Ini.WriteString('Fields', 'Edit18', Edit18.Text);
    Ini.WriteString('Fields', 'Edit19', Edit19.Text);
    Ini.WriteString('Fields', 'Edit20', Edit20.Text);

    // Save item list
    Ini.WriteInteger('Items', 'Count', StringGrid1.RowCount - 1);
    for i := 1 to StringGrid1.RowCount - 1 do
      Ini.WriteString('Items', 'Item' + IntToStr(i - 1), StringGrid1.Cells[0, i]
        + #9 + StringGrid1.Cells[1, i] + #9 + StringGrid1.Cells[2, i] + #9 +
        StringGrid1.Cells[3, i]);
  finally
    Ini.Free;
  end;
end;

// ============================================================
// LoadSettings — Restore field values and items from INI file
// ============================================================

procedure TForm1.LoadSettings;
var
  Ini: TIniFile;
  IniPath: string;
  i, Count: Integer;
  Line: string;
  Parts: TArray<string>;
begin
  IniPath := ExtractFilePath(Application.ExeName) + 'receiptTest.ini';
  if not FileExists(IniPath) then
  begin
    // No INI file — initialize with default items
    StringGrid1.RowCount := 4;
    StringGrid1.Cells[0, 1] := '개인(성인)';
    StringGrid1.Cells[1, 1] := '6000';
    StringGrid1.Cells[2, 1] := '2';
    StringGrid1.Cells[3, 1] := '12000';
    StringGrid1.Cells[0, 2] := '개인(경로)';
    StringGrid1.Cells[1, 2] := '3000';
    StringGrid1.Cells[2, 2] := '1';
    StringGrid1.Cells[3, 2] := '3000';
    StringGrid1.Cells[0, 3] := '주차요금제(승용차)';
    StringGrid1.Cells[1, 3] := '0';
    StringGrid1.Cells[2, 3] := '1';
    StringGrid1.Cells[3, 3] := '0';
    Exit;
  end;

  Ini := TIniFile.Create(IniPath);
  try
    // Restore Edit fields (use current DFM value as default)
    Edit1.Text := Ini.ReadString('Fields', 'Edit1', Edit1.Text);
    Edit2.Text := Ini.ReadString('Fields', 'Edit2', Edit2.Text);
    Edit3.Text := Ini.ReadString('Fields', 'Edit3', Edit3.Text);
    Edit4.Text := Ini.ReadString('Fields', 'Edit4', Edit4.Text);
    Edit5.Text := Ini.ReadString('Fields', 'Edit5', Edit5.Text);
    Edit6.Text := Ini.ReadString('Fields', 'Edit6', Edit6.Text);
    Edit7.Text := Ini.ReadString('Fields', 'Edit7', Edit7.Text);
    Edit8.Text := Ini.ReadString('Fields', 'Edit8', Edit8.Text);
    Edit9.Text := Ini.ReadString('Fields', 'Edit9', Edit9.Text);
    Edit10.Text := Ini.ReadString('Fields', 'Edit10', Edit10.Text);
    Edit11.Text := Ini.ReadString('Fields', 'Edit11', Edit11.Text);
    Edit12.Text := Ini.ReadString('Fields', 'Edit12', Edit12.Text);
    Edit13.Text := Ini.ReadString('Fields', 'Edit13', Edit13.Text);
    Edit14.Text := Ini.ReadString('Fields', 'Edit14', Edit14.Text);
    Edit15.Text := Ini.ReadString('Fields', 'Edit15', Edit15.Text);
    Edit16.Text := Ini.ReadString('Fields', 'Edit16', Edit16.Text);
    Edit17.Text := Ini.ReadString('Fields', 'Edit17', Edit17.Text);
    Edit18.Text := Ini.ReadString('Fields', 'Edit18', Edit18.Text);
    Edit19.Text := Ini.ReadString('Fields', 'Edit19', Edit19.Text);
    Edit20.Text := Ini.ReadString('Fields', 'Edit20', Edit20.Text);

    // Restore item list
    Count := Ini.ReadInteger('Items', 'Count', 0);
    if Count > 0 then
    begin
      StringGrid1.RowCount := Count + 1;
      for i := 0 to Count - 1 do
      begin
        Line := Ini.ReadString('Items', 'Item' + IntToStr(i), '');
        Parts := Line.Split([#9]);
        if Length(Parts) >= 4 then
        begin
          StringGrid1.Cells[0, i + 1] := Parts[0];
          StringGrid1.Cells[1, i + 1] := Parts[1];
          StringGrid1.Cells[2, i + 1] := Parts[2];
          StringGrid1.Cells[3, i + 1] := Parts[3];
        end;
      end;
    end
    else
    begin
      // No item data — keep at least 1 empty row
      StringGrid1.RowCount := 2;
    end;
  finally
    Ini.Free;
  end;
end;

// ============================================================
// BtnSaveClick — Save current settings to INI file
// ============================================================

procedure TForm1.BtnSaveClick(Sender: TObject);
begin
  SaveSettings;
  ShowMessage('설정이 저장되었습니다.');
end;

// ============================================================
// BtnAddRowClick — Add a new empty row to the item grid
// ============================================================

procedure TForm1.BtnAddRowClick(Sender: TObject);
begin
  StringGrid1.RowCount := StringGrid1.RowCount + 1;
end;

// ============================================================
// BtnDelRowClick — Delete the selected row from the item grid
// ============================================================

procedure TForm1.BtnDelRowClick(Sender: TObject);
var
  i, j: Integer;
begin
  if StringGrid1.RowCount <= 2 then
  begin
    ShowMessage('최소 1개 품목은 유지해야 합니다.');
    Exit;
  end;
  if StringGrid1.Row < 1 then
    Exit;

  // Shift rows up from the selected row
  for i := StringGrid1.Row to StringGrid1.RowCount - 2 do
    for j := 0 to StringGrid1.ColCount - 1 do
      StringGrid1.Cells[j, i] := StringGrid1.Cells[j, i + 1];

  StringGrid1.RowCount := StringGrid1.RowCount - 1;
end;

// ============================================================
// BtnCalcAmountClick — Auto-calculate Amount (UnitPrice * Quantity)
// ============================================================

procedure TForm1.BtnCalcAmountClick(Sender: TObject);
var
  i: Integer;
  UnitPrice, Qty: Integer;
begin
  for i := 1 to StringGrid1.RowCount - 1 do
  begin
    UnitPrice := StrToIntDef(StringGrid1.Cells[1, i], 0);
    Qty := StrToIntDef(StringGrid1.Cells[2, i], 0);
    StringGrid1.Cells[3, i] := IntToStr(UnitPrice * Qty);
  end;
end;

end.
