unit FileFunc;

interface
uses Windows, SysUtils;

procedure LoadFile(openthis: string);

var
  myfile: file;
  filearray: array of byte;
  fs: integer;

implementation

{ Copy file to memory. }

procedure LoadFile(openthis: string);
begin
  if FileExists(openthis) then
    begin
    AssignFile(myfile,openthis); // Get file.
    FileMode := fmOpenRead; // Read only.
    Reset(myfile,1);
    SetLength(filearray,FileSize(myfile)); // Match array size to file size.
    BlockRead(myfile,filearray[0],FileSize(myfile)); // Copy file to memory.
    CloseFile(myfile); // Close file.
    fs := Length(filearray);
    end;
end;

end.
