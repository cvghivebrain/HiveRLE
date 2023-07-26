program PHiveRLE;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  FileFunc in 'FileFunc.pas';

var
  inpos, outpos, repcount, unicount: integer;
  outarray: array of byte;
  outfile: string;

{ Find the number of bytes repeated starting at address A. }

function FindRepeat(A: integer): integer;
begin
  result := 1;
  // Increment until different byte is found, the file ends or the max count is reached.
  while (filearray[A] = filearray[A+result]) and (A+result < fs) and (result < 128) do Inc(result);
end;

{ Find the number of non-repeating bytes starting at address A. }

function FindUnique(A: integer): integer;
begin
  result := 0;
  // Increment until repeated byte is found, the file ends or the max count is reached.
  while (filearray[A+result] <> filearray[A+result+1]) and (A+result < fs) and (result < 127) do Inc(result);
end;

begin
  { Program start }

  if ParamCount < 1 then // Check if program was run with parameters.
    begin
    WriteLn('Usage: hiverle {infile} {outfile}');
    exit;
    end;
  if not FileExists(ParamStr(1)) then // Check if input file is valid.
    begin
    WriteLn(ParamStr(1)+' not found.');
    exit;
    end;

  LoadFile(ParamStr(1)); // Copy input file to memory.
  SetLength(outarray,fs*2); // Assume output will be larger than input file (it shouldn't be).
  inpos := 0;
  outpos := 0;

  while inpos < fs do
    begin
    repcount := FindRepeat(inpos); // Get length of repeating byte sequence.
    if repcount > 1 then
      begin
      outarray[outpos] := 256-repcount; // Store count as negative byte.
      outarray[outpos+1] := filearray[inpos]; // Store value.
      //WriteLn(IntToStr(filearray[inpos])+' repeated '+IntToStr(repcount)+' times.');
      outpos := outpos+2;
      inpos := inpos+repcount; // Skip to end of repeating sequence.
      end
    else
      begin
      unicount := FindUnique(inpos); // Get length of unique byte sequence.
      outarray[outpos] := unicount; // Store count.
      Move(filearray[inpos],outarray[outpos+1],unicount); // Copy whole sequence.
      //WriteLn('Sequence of '+IntToStr(unicount)+' unique bytes.');
      outpos := outpos+unicount+1;
      inpos := inpos+unicount; // Skip to end of sequence.
      end;
    end;
  outarray[outpos] := 0; // End of file flag.

  if ParamStr(2) = '' then outfile := ChangeFileExt(ParamStr(1),'.hrl') // Create hrl file if no output is set.
    else outfile := ParamStr(2);
  AssignFile(myfile,outfile); // Open file.
  FileMode := fmOpenReadWrite;
  ReWrite(myfile,1);
  BlockWrite(myfile,outarray[0],outpos+1); // Copy contents of array to file.
  CloseFile(myfile); // Close file.
end.