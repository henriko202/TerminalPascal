
Program TTY;
{$MODE OBJFPC}

Uses crt, sysutils, strutils, Classes;

Type 
  TStringArray = array Of string;
  TSysCharSet = set Of AnsiChar;

Var 
  entrada: String;
  res : String;
  tam : integer;
  c : TSysCharSet;
  arq: TextFile;
  Str: String;

Begin
  // teve que ser feito pois extractword não aceita char
  c := [];
  include(c, ' ');

  entrada := '';
  While (CompareText(entrada,'exit')<>0) Do
    Begin
      write('>');
      readLn(entrada);

      res := ExtractWord(2 ,entrada,c);
      tam := WordCount(res,c);
      entrada := ExtractWord(1,entrada,c);

      // writeln('entrada: ' + entrada);
      // writeln('res: ' + res);
      // writeln('tam: ' + IntToStr(tam));

      Case entrada Of 
        'man' :
                //terminar manuais para o resto dos comandos
                Begin
                  Case res Of 
                    'man' : writeln('Mostra um manual sobre o comando fornecido'
                            );
                    // caso padrão, comando vazio ou inexistente
                    Else
                      Begin
                        If (tam=0) Then
                          Begin
                            writeln('Qual manual gostaria de ver?');
                          End;
                        // if then else nao funciona (?????)
                        If (tam<>0) Then
                          Begin
                            writeln('Comando ' + res + ' inexistente!');
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
                   AssignFile(arq, res);
                  {$I+}
                   If (tam<>0) Then
                     Begin
                       Try
                         Reset(arq);
                         Repeat
                           Readln(arq, Str);
                           Writeln(Str);
                         Until (EOF(arq));
                         CloseFile(arq);
                       Except
                         on E: EInOutError Do writeln('Erro na leitura: '+E.
                                                      ClassName
                                                      +'/'+E.Message);
                     End;
                 End;
        If (tam=0) Then
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
