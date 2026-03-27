program receiptPrj;

uses
  Vcl.Forms,
  receiptTest in 'receiptTest.pas' {Form1},
  receipt in 'receipt.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
