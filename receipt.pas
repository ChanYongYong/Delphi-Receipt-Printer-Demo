unit receipt;

interface

uses
  System.SysUtils, System.Classes;

type
  TReceiptItem = record
    ItemName: string;     // 품명
    UnitPrice: Integer;   // 단가
    Quantity: Integer;    // 수량
    Amount: Integer;      // 금액
  end;

  TReceiptTotals = record
    OrderTotal: Integer;   // 주문합계
    SupplyPrice: Integer;  // 공급가
    Vat: Integer;          // 부가세
    TotalAmount: Integer;  // 합계금액
  end;

  TReceiptPayment = record
    PaymentMethod: string;   // 신용카드결제
    CardCompany: string;     // 현대카드
    CardNumber: string;      // 40457700
    InstallmentType: string; // 일시불/IC
    ApprovalNumber: string;  // 00876239
    ApprovedAmount: Integer; // 15000
  end;

  TReceiptData = record
    // 가맹점 (1-5)
    MerchantName: string;
    BusinessRegNumber: string;
    RepresentativeName: string;
    MerchantPhone: string;
    MerchantAddress: string;
    // 티켓 (6-9)
    TicketTitle: string;
    ReceiptNumber: string;
    PosId: string;
    CashierName: string;
    // 품목 (10)
    Items: TArray<TReceiptItem>;
    // 합계 (11)
    Totals: TReceiptTotals;
    // 결제 (12-17)
    Payment: TReceiptPayment;
    // 기타 (18-19)
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
  RECEIPT_WIDTH = 385;

// ============================================================
// Private — 프린터 선택
// ============================================================

class procedure TReceiptPrinter.SelectPrinter(const APrinterName: string);
var
  i: Integer;
begin
  for i := 0 to Printer.Printers.Count - 1 do
  begin
    if Printer.Printers[i] = APrinterName then
    begin
      Printer.PrinterIndex := i;
      Exit;
    end;
  end;
end;

// ============================================================
// Private — 영수증 출력
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

begin
  SelectPrinter(APrinterName);
  Printer.BeginDoc;
  try
    posY := 10;
    posX := 5;

    // ---- 헤더: [영수증] 가맹점명 ----
    Printer.Canvas.Font.Name := '굴림체';
    Printer.Canvas.Font.Size := 12;
    Printer.Canvas.Font.Style := [fsBold];
    PrintCenter('[영수증] ' + AData.MerchantName);

    // ---- 가맹점 정보 ----
    Printer.Canvas.Font.Size := 8;
    Printer.Canvas.Font.Style := [];
    PrintLine(AData.BusinessRegNumber + ' / ' +
      AData.RepresentativeName + ' / ' + AData.MerchantPhone);
    PrintLine(AData.MerchantAddress);
    PrintBlankLine;

    // ---- 티켓 제목 ----
    Printer.Canvas.Font.Size := 10;
    Printer.Canvas.Font.Style := [fsBold];
    PrintCenter(AData.TicketTitle);

    // ---- 영수번호, POS ID ----
    Printer.Canvas.Font.Size := 8;
    Printer.Canvas.Font.Style := [];
    PrintLine('영수증 # ' + AData.ReceiptNumber +
      '  포스 ID : ' + AData.PosId);
    PrintRight(AData.CashierName);
    PrintBlankLine;

    // ---- 품목 헤더 ----
    PrintLine('품명          단가    수량    금액');
    PrintBlankLine;

    // ---- 품목 리스트 ----
    for i := 0 to Length(AData.Items) - 1 do
    begin
      PrintLine(Format('%-14s %6s %4d %8s',
        [AData.Items[i].ItemName,
         FormatFloat(',0', AData.Items[i].UnitPrice),
         AData.Items[i].Quantity,
         FormatFloat(',0', AData.Items[i].Amount)]));
    end;
    PrintBlankLine;

    // ---- 합계 ----
    PrintLine('주문합계     공급가     부가세');
    PrintLine(Format('%8s   %8s   %8s',
      [FormatFloat(',0', AData.Totals.OrderTotal),
       FormatFloat(',0', AData.Totals.SupplyPrice),
       FormatFloat(',0', AData.Totals.Vat)]));
    PrintBlankLine;
    Printer.Canvas.Font.Style := [fsBold];
    PrintLine('합계 금액 : ' +
      FormatFloat(',0', AData.Totals.TotalAmount));
    Printer.Canvas.Font.Style := [];
    PrintBlankLine;

    // ---- 결제 정보 ----
    PrintDivider;
    PrintCenter('※※ [' + AData.Payment.PaymentMethod + '] ※※');
    PrintLine('카드사명: ' + AData.Payment.CardCompany);
    PrintLine('카드번호: ' + AData.Payment.CardNumber +
      '  ' + AData.Payment.InstallmentType);
    PrintLine('승인번호: ' + AData.Payment.ApprovalNumber +
      '  승인금액: ' + FormatFloat(',0', AData.Payment.ApprovedAmount));
    PrintBlankLine;

    // ---- 발행일시 ----
    PrintCenter('발 행 일 시 : ' + AData.IssuedAt);
    PrintBlankLine;

    // ---- 고객용/매장용 ----
    Printer.Canvas.Font.Style := [fsBold];
    PrintCenter(AData.ReceiptCopyType);
    Printer.Canvas.Font.Style := [];

  finally
    Printer.EndDoc;
  end;
end;

// ============================================================
// Public — TStringList/TStrings → TArray<TReceiptItem> 변환
// 각 줄 형식: 품명[탭]단가[탭]수량[탭]금액
// ============================================================

class function TReceiptPrinter.ParseItems(AItems: TStrings): TArray<TReceiptItem>;
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
// Public — 외부에서 호출하는 메인 메서드
// ============================================================

class procedure TReceiptPrinter.PrintReceipt(const APrinterName: string;
  const AData: TReceiptData);
begin
  if APrinterName = '' then
    Exit;

  DoPrint(APrinterName, AData);
end;

end.
