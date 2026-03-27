unit receiptTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;     // 가맹점명
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;     // 사업자번호
    Label3: TLabel;
    Edit3: TEdit;     // 대표자명
    Label4: TLabel;
    Edit4: TEdit;     // 전화번호
    Label5: TLabel;
    Edit5: TEdit;     // 주소
    Edit6: TEdit;     // 영수증제목
    Label6: TLabel;
    Label7: TLabel;
    Edit7: TEdit;     // 영수번호
    Label8: TLabel;
    Edit8: TEdit;     // POS ID
    Label9: TLabel;
    Edit9: TEdit;     // 담당자
    Label10: TLabel;
    Edit10: TEdit;    // 영수증유형
    Label20: TLabel;
    Memo1: TMemo;     // 품목 리스트
    Label11: TLabel;
    Edit11: TEdit;    // 공급가
    Label12: TLabel;
    Edit12: TEdit;    // 부가세
    Label13: TLabel;
    Edit13: TEdit;    // 결제방법
    Label14: TLabel;
    Edit14: TEdit;    // 카드사명
    Label15: TLabel;
    Edit15: TEdit;    // 카드번호
    Label16: TLabel;
    Edit16: TEdit;    // 할부유형
    Label17: TLabel;
    Edit17: TEdit;    // 승인번호
    Label18: TLabel;
    Edit18: TEdit;    // 승인금액
    Label19: TLabel;
    Edit19: TEdit;    // 발행일시
    Label21: TLabel;
    Edit20: TEdit;    // 프린터명
    Button1: TButton; // 인쇄
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Printers, receipt;

procedure TForm1.Button1Click(Sender: TObject);
var
  Data: TReceiptData;
  i: Integer;
  OrderTotal: Integer;
begin
  // 가맹점 정보
  Data.MerchantName := Edit1.Text;
  Data.BusinessRegNumber := Edit2.Text;
  Data.RepresentativeName := Edit3.Text;
  Data.MerchantPhone := Edit4.Text;
  Data.MerchantAddress := Edit5.Text;

  // 티켓 정보
  Data.TicketTitle := Edit6.Text;
  Data.ReceiptNumber := Edit7.Text;
  Data.PosId := Edit8.Text;
  Data.CashierName := Edit9.Text;

  // 영수증 유형
  Data.ReceiptCopyType := Edit10.Text;

  // 품목 파싱 — Memo1.Lines(TStrings)를 ParseItems에 전달
  Data.Items := TReceiptPrinter.ParseItems(Memo1.Lines);

  // 주문합계 자동 계산
  OrderTotal := 0;
  for i := 0 to Length(Data.Items) - 1 do
    OrderTotal := OrderTotal + Data.Items[i].Amount;

  // 합계
  Data.Totals.SupplyPrice := StrToIntDef(Edit11.Text, 0);
  Data.Totals.Vat := StrToIntDef(Edit12.Text, 0);
  Data.Totals.OrderTotal := OrderTotal;
  Data.Totals.TotalAmount := Data.Totals.SupplyPrice + Data.Totals.Vat;

  // 결제 정보
  Data.Payment.PaymentMethod := Edit13.Text;
  Data.Payment.CardCompany := Edit14.Text;
  Data.Payment.CardNumber := Edit15.Text;
  Data.Payment.InstallmentType := Edit16.Text;
  Data.Payment.ApprovalNumber := Edit17.Text;
  Data.Payment.ApprovedAmount := StrToIntDef(Edit18.Text, 0);

  // 발행일시
  Data.IssuedAt := Edit19.Text;

  // 인쇄 (Edit20에 입력한 프린터명 사용)
  if Trim(Edit20.Text) = '' then
  begin
    ShowMessage('프린터명을 입력해주세요.');
    Exit;
  end;
  TReceiptPrinter.PrintReceipt(Edit20.Text, Data);
end;

end.
