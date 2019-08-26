
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
  tamArg0 : integer;
  tamArg1 : integer;
  tamArg2 : integer;
  charset : TSysCharSet;
  arq: TextFile;
  outputString: String;
  currLocation : String;

Begin
  // teve que ser feito pois extractword não aceita char
  charset := [];
  include(charset, ' ');

  entrada := '';
  While (CompareText(entrada,'exit')<>0) Do
    Begin
      write('>');
      readLn(entrada);

      arg1 := ExtractWord(2 ,entrada,charset);
      tamArg1 := WordCount(arg1,charset);
      arg0 := ExtractWord(1,entrada,charset);

      // writeln('entrada: ' + entrada);
      // writeln('arg1: ' + arg1);
      // writeln('tamArg1: ' + IntToStr(tamArg1));

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
                        If (tamArg1=0) Then
                          Begin
                            writeln('Qual manual gostaria de ver?');
                          End;
                        // if then else nao funciona (?????)
                        If (tamArg1<>0) Then
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
                   If (tamArg1<>0) Then
                     Begin
                       Try
                         reset(arq);
                         Repeat
                           Readln(arq, outputString);
                           Writeln(outputString);
                         Until (EOF(arq));
                         CloseFile(arq);
                       Except
                         on E: EInOutError Do writeln('Erro na leitura: '+E.
                                                      ClassName
                                                      +'/'+E.Message);
                     End;
                 End;
        If (tamArg1=0) Then
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
      'rmdir':
               Begin
                 writeln('NYI!');
               End;
      'mkdir':
               Begin
                 writeln('NYI!');
               End;
      'clear' : clrscr();
      Else
        writeln('Comando não reconhecido!');
    End;
End;
End.
