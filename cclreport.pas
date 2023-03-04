unit CCLReport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, EditBtn, StdCtrls,
  ExtCtrls, lconvencoding;

type

  { TCCLReportForm }

  TCCLReportForm = class(TForm)
    ButExport: TButton;
    ButCanc: TButton;
    CCLDateStart: TDateEdit;
    CCLDateEnd: TDateEdit;
    LabRepEnd: TLabel;
    LabRepStart: TLabel;
    RadSummary: TRadioButton;
    RadDetail: TRadioButton;
    RadioGroup1: TRadioGroup;
    procedure ButCancClick(Sender: TObject);
    procedure ButExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  CCLReportForm: TCCLReportForm;

implementation

uses
  Control;

{$R *.lfm}

{ TCCLReportForm }

procedure TCCLReportForm.FormShow(Sender: TObject);
begin
  CCLReportForm.Top := ControlForm.Top + 10;
  CCLReportForm.Left := ControlForm.Left + 10;

end;

procedure TCCLReportForm.ButCancClick(Sender: TObject);
begin
  CCLReportForm.Close;
end;

procedure TCCLReportForm.ButExportClick(Sender: TObject);
var
  ReportFile: TextFile;
  line : string;
begin
   if CCLDateStart.Text = '' then
   begin
     ShowMessage('Please fill in the Report From date');
     exit;
   end;
   if CCLDateEnd.Text = '' then
   begin
     ShowMessage('Please fill in the Report To date');
     exit;
   end;
   ControlForm.SaveDialog1.Title := 'CCL Report Export';
   ControlForm.SaveDialog1.DefaultExt:='.csv';
   ControlForm.SaveDialog1.Filter := 'CSV Files|*.csv';
   if ControlForm.SaveDialog1.Execute then
   begin
     AssignFile(ReportFile, ControlForm.SaveDialog1.FileName);
     Rewrite(ReportFile);

     if RadSummary.Checked then
     begin
       ControlForm.SQLMainQuery.SQL.Text:='SELECT cclname, cclcopy, COUNT(DISTINCT cclevent) AS usage FROM cclrecord WHERE ccldate >= julianday(:STARTDATE) AND ccldate <= julianday(:ENDDATE) GROUP BY songId';
       writeln(ReportFile, '"First Line / Chorus","Copyright","Used Count"');
     end
     else
     begin
       ControlForm.SQLMainQuery.SQL.Text:='SELECT cclname, cclcopy, strftime("%d-%m-%Y",ccldate) AS eventdate, cclevent FROM cclrecord WHERE ccldate >= julianday(:STARTDATE) AND ccldate <= julianday(:ENDDATE) GROUP BY songId, date(ccldate), cclevent';
       writeln(ReportFile, '"First Line / Chorus","Copyright","Date","Event"');
     end;
     ControlForm.SQLMainQuery.Params.ParamByName('STARTDATE').AsString := COPY(CCLDateStart.Text, 7,4) + '-' + COPY(CCLDateStart.Text, 4, 2) + '-' + COPY(CCLDateStart.Text, 1, 2);
     ControlForm.SQLMainQuery.Params.ParamByName('ENDDATE').AsString := COPY(CCLDateEnd.Text, 7,4) + '-' + COPY(CCLDateEnd.Text, 4, 2) + '-' + COPY(CCLDateEnd.Text, 1, 2);

     ControlForm.SQLMainQuery.Open;
     while NOT ControlForm.SQLMainQuery.EOF do
     begin
       Line := '"' + ControlForm.SQLMainQuery.FieldByName('cclname').AsString + '","' + ControlForm.SQLMainQuery.FieldByName('cclcopy').AsString + '",';
       if RadSummary.Checked then
         Line := Line + ControlForm.SQLMainQuery.FieldByName('usage').AsString
       else
         Line := Line + '"' + ControlForm.SQLMainQuery.FieldByName('eventdate').AsString + '","' + ControlForm.SQLMainQuery.FieldByName('cclevent').AsString + '"';
       Line := ConvertEncoding(Line, GuessEncoding(Line), EncodingUTF8);

       writeln(ReportFile,Line);
       ControlForm.SQLMainQuery.Next;
     end;
     ControlForm.SQLMainQuery.Close;

     CloseFile(ReportFile);
     CCLReportForm.Close;
   end;
end;

end.

