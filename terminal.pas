
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
        'clear' :
                  Begin
                    clrscr();
                  End;
        Else
          writeln('Comando não reconhecido!');
      End;
    End;
End.
