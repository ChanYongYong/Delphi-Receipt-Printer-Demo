unit receipt;

interface

uses
  System.SysUtils, System.Classes;

type
  TReceiptItem = record
    ItemName: string; // Item name
    UnitPrice: Integer; // Unit price
    Quantity: Integer; // Quantity
    Amount: Integer; // Amount (UnitPrice * Quantity)
  end;

  TReceiptTotals = record
    OrderTotal: Integer; // Order total (sum of all item amounts)
    SupplyPrice: Integer; // Supply price
    Vat: Integer; // VAT (Value Added Tax)
    TotalAmount: Integer; // Total amount (SupplyPrice + VAT)
  end;

  TReceiptPayment = record
    PaymentMethod: string; // Payment method (e.g. 'Credit Card')
    CardCompany: string; // Card company (e.g. 'Hyundai Card')
    CardNumber: string; // Card number (e.g. '40457700')
    InstallmentType: string; // Installment type (e.g. 'Lump Sum/IC')
    ApprovalNumber: string; // Approval number (e.g. '00876239')
    ApprovedAmount: Integer; // Approved amount (e.g. 15000)
  end;

  TReceiptData = record
    // Merchant info
    MerchantName: string;
    BusinessRegNumber: string;
    RepresentativeName: string;
    MerchantPhone: string;
    MerchantAddress: string;
    // Ticket info
    TicketTitle: string;
    ReceiptNumber: string;
    PosId: string;
    CashierName: string;
    // Item list
    Items: TArray<TReceiptItem>;
    // Totals
    Totals: TReceiptTotals;
    // Payment info
    Payment: TReceiptPayment;
    // Other
    IssuedAt: string;
    ReceiptCopyType: string;
  end;

  TReceiptPrinter = class
  private
    class procedure SelectPrinter(const APrinterName: string);
    class procedure DoPrint(const APrinterName: string;
      const AData: TReceiptData);
  public
    class function ParseItems(AItems: TStrings): TArray<TReceiptItem>;
    class procedure PrintReceipt(const APrinterName: string;
      const AData: TReceiptData);
  end;

implementation

uses
  Printers, Graphics;

const
  LINE_PITCH = 5;
  RECEIPT_WIDTH = 500;


// ============================================================
// Public — Print receipt (main entry point)
// ============================================================

class procedure TReceiptPrinter.PrintReceipt(const APrinterName: string;
  const AData: TReceiptData);
<<<<<<< HEAD
var
  posY, posX, i: Integer;

  procedure PrintLine(const AText: string);
  begin
    Printer.Canvas.TextOut(posX, posY, AText);
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

  procedure PrintCenter(const AText: string);
  begin
    Printer.Canvas.TextOut(
      (RECEIPT_WIDTH - Printer.Canvas.TextWidth(AText)) div 2,
      posY, AText);
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

  procedure PrintRight(const AText: string);
  begin
    Printer.Canvas.TextOut(
      RECEIPT_WIDTH - Printer.Canvas.TextWidth(AText),
      posY, AText);
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

  procedure PrintDivider;
  var
    CharCount: Integer;
  begin
    CharCount := RECEIPT_WIDTH div Printer.Canvas.TextWidth('=');
    PrintLine(StringOfChar('=', CharCount));
  end;

  procedure PrintBlankLine;
  begin
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

=======
>>>>>>> 4702a1688109359bf7cb1c89ec4820eca793f341
begin
  DoPrint(APrinterName, AData);
end;

  // ============================================================
  // Public — Convert tab-delimited text lines to item array
  // Each line format: ItemName[TAB]UnitPrice[TAB]Quantity[TAB]Amount
  // ============================================================

class function TReceiptPrinter.ParseItems(AItems: TStrings)
  : TArray<TReceiptItem>;
var
  i, Count: Integer;
  Parts: TArray<string>;
  Item: TReceiptItem;
begin
  SetLength(Result, AItems.Count);
  Count := 0;
  for i := 0 to AItems.Count - 1 do
  begin
    if Trim(AItems[i]) = '' then
      Continue;
    Parts := AItems[i].Split([#9]);
    if Length(Parts) >= 4 then
    begin
      Item.ItemName := Parts[0];
      Item.UnitPrice := StrToIntDef(Parts[1], 0);
      Item.Quantity := StrToIntDef(Parts[2], 0);
      Item.Amount := StrToIntDef(Parts[3], 0);
      Result[Count] := Item;
      Inc(Count);
    end;
  end;
  SetLength(Result, Count);
end;


// ============================================================
// Private — Select printer by name
// Falls back to default printer if name is empty or not found
// ============================================================

class procedure TReceiptPrinter.SelectPrinter(const APrinterName: string);
var
  i: Integer;
begin
  // Search for the specified printer name
  for i := 0 to Printer.Printers.Count - 1 do
  begin
    if Printer.Printers[i] = APrinterName then
    begin
      Printer.PrinterIndex := i;
      Exit;
    end;
  end;

  // Printer not found or name is empty — use default printer
  Printer.PrinterIndex := -1;
end;

// ============================================================
// Private — Render receipt layout on printer canvas
// ============================================================

class procedure TReceiptPrinter.DoPrint(const APrinterName: string;
  const AData: TReceiptData);
var
  posY, posX, i: Integer;

  procedure PrintLine(const AText: string);
  begin
    Printer.Canvas.TextOut(posX, posY, AText);
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

  procedure PrintCenter(const AText: string);
  begin
    Printer.Canvas.TextOut((RECEIPT_WIDTH - Printer.Canvas.TextWidth(AText))
      div 2, posY, AText);
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

  procedure PrintRight(const AText: string);
  begin
    Printer.Canvas.TextOut(RECEIPT_WIDTH - Printer.Canvas.TextWidth(AText),
      posY, AText);
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

  procedure PrintDivider;
  begin
    PrintLine('-------------------------------------------------');
  end;

  procedure PrintBlankLine;
  begin
    posY := posY + Printer.Canvas.TextHeight('A') + LINE_PITCH;
  end;

begin
  SelectPrinter(APrinterName);
  Printer.BeginDoc;
  try
    posY := 50;
    posX := 5;

    // ---- Header: [Receipt] Merchant name (small text) ----
    Printer.Canvas.Font.Name := '굴림체';
    Printer.Canvas.Font.Size := 8;
    Printer.Canvas.Font.Style := [fsBold];
    PrintLine('[영수증] ' + AData.MerchantName);

    // ---- Merchant info ----
    Printer.Canvas.Font.Size := 7;
    Printer.Canvas.Font.Style := [];
    PrintLine(AData.BusinessRegNumber + ' / ' + AData.RepresentativeName + ' / '
      + AData.MerchantPhone);

    Printer.Canvas.TextOut(posX, posY, AData.MerchantAddress);
    posY := posY + 30;

    // ---- Ticket title (large text) ----
    Printer.Canvas.Font.Size := 16;
    Printer.Canvas.Font.Style := [fsBold];
    PrintLine(AData.TicketTitle);

    // ---- Receipt number, POS ID, Cashier ----
    Printer.Canvas.Font.Size := 8;
    Printer.Canvas.Font.Style := [];
    Printer.Canvas.TextOut(posX, posY, '영수증 # ' + AData.ReceiptNumber);
    PrintRight('포스 ID : ' + AData.PosId);
    PrintRight(AData.CashierName);
    PrintDivider;

    // ---- Item list header ----
    Printer.Canvas.TextOut(posX, posY, '품명');
    PrintRight('단가      수량      금액');
    PrintDivider;

    // ---- Item list ----
    for i := 0 to Length(AData.Items) - 1 do
    begin
      Printer.Canvas.TextOut(posX, posY, '* ' + AData.Items[i].ItemName);
      PrintRight(Format('%8s %6d %10s',
        [FormatFloat(',0', AData.Items[i].UnitPrice), AData.Items[i].Quantity,
        FormatFloat(',0', AData.Items[i].Amount)]));
      posY := posY + LINE_PITCH;
    end;
    PrintDivider;

    // ---- Totals ----
    PrintRight('주문합계       공급가       부가세');
    PrintRight(Format('%10s   %10s   %10s',
      [FormatFloat(',0', AData.Totals.OrderTotal), FormatFloat(',0',
      AData.Totals.SupplyPrice), FormatFloat(',0', AData.Totals.Vat)]));
    PrintDivider;

    // ---- Total amount ----
    Printer.Canvas.Font.Size := 10;
    Printer.Canvas.Font.Style := [fsBold];
    Printer.Canvas.TextOut(posX, posY, '합계 금액:');
    PrintRight(FormatFloat(',0', AData.Totals.TotalAmount) + ' 원');
    Printer.Canvas.Font.Style := [];
    Printer.Canvas.Font.Size := 8;
    PrintDivider;

    // ---- Payment info ----
    Printer.Canvas.Font.Style := [fsBold];
    PrintCenter('※※ [' + AData.Payment.PaymentMethod + '] ※※');
    Printer.Canvas.Font.Style := [];
    PrintLine('카드사명: ' + AData.Payment.CardCompany);
    PrintLine('카드번호: ' + AData.Payment.CardNumber + '  ' +
      AData.Payment.InstallmentType);
    PrintLine('승인번호: ' + AData.Payment.ApprovalNumber + '  승인금액: ' + FormatFloat(',0', AData.Payment.ApprovedAmount));
    PrintDivider;

    // ---- Issued date/time ----
    PrintCenter('발 행 일 시 : ' + AData.IssuedAt);
    PrintDivider;

    // ---- Receipt copy type (Customer / Store) ----
    Printer.Canvas.Font.Size := 16;
    Printer.Canvas.Font.Style := [fsBold];
    PrintCenter(AData.ReceiptCopyType);
    Printer.Canvas.Font.Style := [];

  finally
    Printer.EndDoc;
  end;
end;

end.
