
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
  tam1 : integer;
  tam2 : integer;
  charset : TSysCharSet;
  arq: TextFile;
  outputString: String;
  SR      : TSearchRec;
  texto: Text;

Begin
  // teve que ser feito pois extractword não aceita char
  charset := [];
  include(charset, ' ');

  entrada := '';

  While (CompareText(entrada,'exit')<>0) Do
    Begin
      write(GetCurrentDir);
      write('>');
      readLn(entrada);

      arg0 := ExtractWord(1,entrada,charset);
      arg1 := ExtractWord(2,entrada,charset);
      arg2 := ExtractWord(3,entrada,charset);
      tam1 := WordCount(arg1,charset);
      tam2 := WordCount(arg2,charset);

      Case arg0 Of 
        'help' :
                 Begin
                   writeln('Comandos existentes:');
                   writeln('man, exit, cat, ls, cd, mv, touch, locate, rmdir, mkdir, rm, clear');
                 End;
        'man' :
                //terminar manuais para o arg1to dos comandos
                Begin
                  Case arg1 Of 
                    'man' :
                            Begin
                              writeln('Mostra um manual sobre o comando fornecido');
                            End;
                    'exit' :
                             Begin
                               writeln('Fecha o terminal');
                             End;
                    'cat' :
                            Begin
                              writeln('Mostra o conteúdo de um arquivo passado por argumento');
                            End;
                    'ls' :
                           Begin
                             writeln('Mostra o conteúdo da pasta atual');
                           End;
                    'cd' :
                           Begin
                             writeln('Muda o diretório atual');
                           End;
                    'mv' :
                           Begin
                             writeln('Move ou renomeia um arquivo');
                           End;
                    'touch' :
                              Begin
                                writeln('Cria um arquivo');
                              End;
                    'locate' :
                               Begin
                                 writeln('Procura um arquivo na pasta atual');
                               End;
                    'rmdir' :
                              Begin
                                writeln('Remove um diretório da pasta autal');
                              End;
                    'mkdir' :
                              Begin
                                writeln('Cria um diretório na pasta atual');
                              End;
                    'rm' :
                           Begin
                             writeln('Remove um arquivo da pasta atual');
                           End;
                    'clear' :
                              Begin
                                writeln('Limpa a tela do terminal');
                              End;
                    'help' :
                             Begin
                               writeln('Mostra os comandos existentes');
                             End;
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
              If FindFirst ('*',faAnyFile And faDirectory,SR)=0 Then
                Begin
                  Repeat
                    With SR Do
                      Begin
                        Write(SR.Name + ' ');
                      End;
                  Until FindNext(SR)<>0;
                End;
              writeln();
              FindClose(SR);
            End;
      'cd':
            Begin
              If (tam1<>0) Then
                Begin
                  Try
                    ChDir (arg1);
                  Except
                    on E: EInOutError Do Writeln (E.Message);
                End;
            End;
      If (tam1=0) Then ChDir('/home/'+GetEnvironmentVariable('USER'));

    End;
  'mv':
        Begin
          If (tam1<>0)Then
            If (tam2<>0) Then
              Begin
                If Not(renamefile(arg1, arg2)) Then writeln('Erro ao mover arquivo!');
              End;
        End;
  'touch':
           Begin
             If (tam1<>0) Then filecreate(arg1);
             If (tam1=0) Then writeln('Digite o nome do arquivo para ser criado!');
           End;
  'locate':
            Begin
              If (tam1<>0) Then
                Begin
                  If FindFirst ('*'+arg1+'*',faAnyFile And faDirectory,SR)=0 Then
                    Begin
                      Repeat
                        With SR Do
                          Begin
                            Write(SR.Name + ' ');
                          End;
                      Until FindNext(SR)<>0;
                    End;
                  writeln();
                  FindClose(SR);
                End;
              If (tam1=0) Then writeln('Digite o nome do arquivo!');
            End;
  'rmdir':
           Begin
             Try
               If (tam1 <> 0 ) Then rmdir(arg1);
             Except
               on E: EInOutError Do writeln(E.Message);
           End;
  If (tam1=0) Then writeln('Digite um diretório para excluir');
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
If (tam1=0) Then writeln('Digite um arquivo para excluir');

End;
'mkdir':
         Begin
           Try
             If (tam1 <> 0 ) Then mkdir(arg1);
           Except
             on E: EInOutError Do writeln(E.Message);
         End;
If (tam1=0) Then writeln('Digite um diretório para criar');

End;
'clear' : clrscr();
Else
  writeln('Comando não reconhecido!');
End;
End;
End.
