
Program TTY;
{$MODE OBJFPC}

Uses crt, sysutils, strutils, Classes;

Type 
  TStringArray = array Of string;
  TSysCharSet = set Of AnsiChar;

Var 
  entrada: String;
  arg0 : String;
  arg1 : String;
  arg2 : String;
  tam0 : integer;
  tam1 : integer;
  tam2 : integer;
  charset : TSysCharSet;
  arq: TextFile;
  outputString: String;
  currLocation : String;
  Path    : String;
  SR      : TSearchRec;
  DirList : TStrings;
  texto: Text;

Begin
  // teve que ser feito pois extractword não aceita char
  charset := [];
  include(charset, ' ');

  entrada := '';
  GetDir (0,currLocation);

  While (CompareText(entrada,'exit')<>0) Do
    Begin
      write(currLocation);
      write('>');
      readLn(entrada);

      arg0 := ExtractWord(1,entrada,charset);
      arg1 := ExtractWord(2,entrada,charset);
      arg2 := ExtractWord(3,entrada,charset);
      tam0 := WordCount(arg0,charset);
      tam1 := WordCount(arg1,charset);
      tam2 := WordCount(arg2,charset);


      // writeln('entrada: ' + entrada);
      // writeln('arg1: ' + arg1);
      // writeln('tam1: ' + IntToStr(tam1));

      Case arg0 Of 
        'man' :
                //terminar manuais para o arg1to dos comandos
                Begin
                  Case arg1 Of 
                    'man' : writeln('Mostra um manual sobre o comando fornecido'
                            );
                    // caso padrão, comando vazio ou inexistente
                    Else
                      Begin
                        If (tam1=0) Then
                          Begin
                            writeln('Qual manual gostaria de ver?');
                          End;
                        // if then else nao funciona (?????)
                        If (tam1<>0) Then
                          Begin
                            writeln('Comando ' + arg1 + ' inexistente!');
                          End;
                      End;
                  End;
                End;
        'exit' :
                 Begin
                   writeln('Bye!');
                   exit;
                 End;
        '' : write();
        'cat'  :
                 Begin
                   AssignFile(arq, arg1);
                  {$I+}
                   If (tam1<>0) Then
                     Begin
                       Try
                         reset(arq);
                         Repeat
                           Readln(arq, outputString);
                           Writeln(outputString);
                         Until (EOF(arq));
                         CloseFile(arq);
                       Except
                         on E: EInOutError Do writeln(E.Message);
                     End;
                 End;
        If (tam1=0) Then
          Begin
            writeln('Digite um arquivo para ler!');
          End;
      End;
      'ls':
            Begin
              writeln('NYI!');
            End;
      'cd':
            Begin
              writeln('NYI!');
            End;
      'mv':
            Begin
              writeln('NYI!');
            End;
      'locate':
                Begin
                  writeln('NYI!');
                End;
      'rmdir':
               Begin
                 Try
                   If (tam1 <> 0 ) Then rmdir(arg1);
                 Except
                   on E: EInOutError Do writeln(E.Message);
               End;
    End;
  'rm' :
         Begin
           Try
             If (tam1 <> 0 ) Then
               Begin
                 assign(texto,arg1);
                 erase(texto);
               End;
           Except
             on E: EInOutError Do writeln(E.Message);
         End;
End;
'mkdir':
         Begin
           Try
             If (tam1 <> 0 ) Then mkdir(arg1);
           Except
             on E: EInOutError Do writeln(E.Message);
         End;
End;
'clear' : clrscr();
Else
  writeln('Comando não reconhecido!');
End;
End;
End.
