//Projeto 1 FILE CONQUEROR _ Explorador de arquivos com Shell
//Alunos: Henriko Alberton, Erica Saito

program TTY;

{$MODE OBJFPC}{$H+}

//Bibliotecas utilizadas
uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  crt,
  SysUtils,
  strutils,
  Classes;

//Criando tipos não primitivos
type
  TSysCharSet = set of AnsiChar;

//Variáveis utilizadas 
var
  entrada: string;
  i: integer;
  counter: integer;
  arg0: string;
  arg1: string;
  str0: string;
  str1: string;
  str2: string;
  tam1: integer;
  tam2: integer;
  charset: TSysCharSet;
  cArgs: TSysCharSet;
  arq: TextFile;
  outputString: string;
  SR: TSearchRec;

function copy(Source, Target: string): boolean;
var
  Buffer: TMemoryStream;
begin
  result := false;
  Buffer := TMemoryStream.Create;
  try
    Buffer.LoadFromFile(Source);
    Buffer.SaveToFile(Target);
    result := true
  except
    writeln('Erro ao copiar arquivo!');
  end;
  Buffer.Free;
end;

procedure procura(const diretorio, arquivo: string);
var
  SR: TSearchRec;
  caminho: string;
begin
  caminho := IncludeTrailingBackslash(diretorio);
  if FindFirst(caminho + arquivo, faAnyFile - faDirectory, SR) = 0 then
    try
      repeat
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;

  if FindFirst(caminho + '*', faDirectory, SR) = 0 then
    try
      repeat
        if ((SR.Attr and faDirectory) <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then
          procura(caminho + SR.Name, arquivo);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
end;

procedure deletaDir(const Nome: string);
var
  SR: TSearchRec;
begin
  if FindFirst(Nome + '/*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Attr and faDirectory <> 0) then
        begin
          if (SR.Name <> '.') and (SR.Name <> '..') then
            deletaDir(Nome + '/' + SR.Name);
        end
        else
          DeleteFile(Nome + '/' + SR.Name);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
    RemoveDir(Nome);
  end;
end;

function promptDir(const diretorio, arquivo: string): integer;
var
  SR: TSearchRec;
  caminho: string;
  j: integer;
  option: string;

begin
  j := 0;
  caminho := IncludeTrailingBackslash(diretorio);
  if FindFirst(caminho + arquivo, faDirectory, SR) = 0 then
  begin
    repeat
      j := j + 1;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if (j = 1) then
  begin
    writeln();
    write('Arquivo ou diretório já existente, deseja sobrescrever? [y/n] ');
    readln(option);
    if (option = 'y') then
      deletaDir(caminho + arquivo)
    else
      result := -1;
  end;
end;

function promptFile(const diretorio, arquivo: string): integer;
var
  SR: TSearchRec;
  caminho: string;
  j: integer;
  option: string;

begin
  j := 0;
  caminho := IncludeTrailingBackslash(diretorio);
  if FindFirst(caminho + arquivo, faAnyFile, SR) = 0 then
  begin
    repeat
      j := j + 1;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if (j = 1) then
  begin
    writeln();
    write('Arquivo ou diretório já existente, deseja sobrescrever? [y/n] ');
    readln(option);
    if (option = 'y') then
      DeleteFile(caminho + arquivo)
    else
      result := -1;
  end;
end;

//Main do programa
begin
  //Teve que ser feito pois extractword não aceita char
  if (argc = 2) then
    ChDir(argv[1]);
  charset := [];
  include(charset, ' ');
  cArgs := [];
  include(cArgs, '-');
  counter := 1;
  entrada := '';

  //Enquanto não for digitado 'exit'
  while (CompareText(entrada, 'exit') <> 0) do
  begin
    arg0 := '';
    arg1 := '';
    write('user@terminal:');
    write(GetCurrentDir);
    write('>');
    readln(entrada);

    for i := 0 to length(entrada) do
    begin
      if (entrada[i] = '-') then
      begin
        if (counter = 1) then
        begin
          arg0 := extractword(counter, entrada, cArgs);
          counter := counter + 1;
        end;
        if (counter = 2) then
        begin
          arg1 := extractword(counter, entrada, cArgs);
          counter := 1;
        end;
      end;
      if (entrada[i] <> '-') then
      begin
        if (counter = 1) then
        begin
          str0 := ExtractWord(counter, entrada, charset);
          counter := counter + 1;
        end;
        if (counter = 2) then
        begin
          str1 := ExtractWord(counter, entrada, charset);
          counter := counter + 1;
        end;
        if (counter = 3) then
        begin
          str2 := ExtractWord(counter, entrada, charset);
          counter := 1;
        end;
      end;
    end;

    tam1 := WordCount(str1, charset);
    tam2 := WordCount(str2, charset);

    //Identificando o comando digitado pelo usuário
    case str0 of
      //man: mostra o manual do comando fornecido
      'man': case str1 of
          'man':
          begin
            writeln('Mostra um manual sobre o comando fornecido');
            writeln('Sinopsys: man [opção]');
          end;
          'exit':
          begin
            writeln('Fecha o terminal');
            writeln('Sinopsys: exit');
          end;
          'cat':
          begin
            writeln('Mostra o conteúdo de um arquivo passado por argumento');
            writeln('Sinopsys: cat [arquivo]');
          end;
          'ls':
          begin
            writeln('Mostra o conteúdo da pasta atual');
            writeln('Sinopsys: ls [argumento1] [argumento2]');
            writeln('Ou pode ser passado o argumento -full (sozinho) que irá mostrar todas as informaçoes dos arquivos e pastas');
            writeln('[argumento1] pode ser:');
            writeln('-valid Não lista as entradas implícitas (. e ..)');
            writeln('-hidden Mostra arquivos e pastas ocultas');
            writeln('-dirs Mostra apenas os diretórios');
            writeln('-files Mostra apenas os arquivos');
            writeln('[argumento2] pode ser:');
            writeln('-sortasc Mostra os arquivos em forma crescente');
            writeln('-sortdesc Mostra os arquivos em forma decrescente');
          end;
          'cd':
          begin
            writeln('Muda o diretório atual');
            writeln('Sinopsys: cd [string]');
          end;
          'move':
          begin
            writeln('Move arquivo ou diretório para destino');
            writeln('Sinopsys: move [source] [target]');
          end;
          'mkfile':
          begin
            writeln('Cria um arquivo');
            writeln('Sinopsys: mkfile [target]');
          end;
          'locate':
          begin
            writeln('Procura um arquivo na pasta atual');
            writeln('Sinopsys: locate [string]');
          end;
          'rmdir':
          begin
            writeln('Remove um diretório da pasta autal');
            writeln('Sinopsys: rmdir [target]');
          end;
          'mkdir':
          begin
            writeln('Cria um diretório na pasta atual');
            writeln('Sinopsys: mkdir [target]');
          end;
          'rmfile':
          begin
            writeln('Remove um arquivo da pasta atual');
            writeln('Sinopsys: rmfile [target]');
          end;
          'clear':
          begin
            writeln('Limpa a tela do terminal');
            writeln('Sinopsys: clear');
          end;
          'help':
          begin
            writeln('Mostra os comandos existentes');
            writeln('Sinopsys: help');
          end;
          'copy':
          begin
            writeln('Copia arquivo/diretório para destino');
            writeln('Sinopsys: copy [source] [target]');
          end;
            // caso padrão, comando inexistente ou mostra os comandos disponíveis
          else if (tam1 = 0) then
            begin
              writeln('Comandos existentes:');
              writeln('ls, cd, mkdir, mkfile, rmdir, rmfile, move, copy, clear, man, locate, cat, help');
              writeln('ls possui certos argumentos, consulte "man ls" para vê-los');
            end
            //se comando não existe
            else
              writeln('Comando ' + str1 + ' inexistente!');
            //Se comando não for fornecido
        end;
      //exit: sai do terminal 
      'exit':
      begin
        writeln('Bye!');
        exit;
      end;
      'exita':
      begin
        writeln('Exitando (sim, isso foi de propósito)');
        exit;
      end;
      //caso não seja digitado nada 
      '': write();
      //cat: Lê o conteúdo de um arquivo
      'cat':
      begin
        AssignFile(arq, str1);
        if (tam1 <> 0) then
          //Inicia a leitura do arquivo                    
          try
            reset(arq);
            repeat
              readln(arq, outputString);
              writeln(outputString);
            until (EOF(arq));
            CloseFile(arq);
          except
            on E: EInOutError do
              writeln(E.Message);
          end;
        //Se não for passado nenhum arquivo 
        if (tam1 = 0) then
          writeln('Digite um arquivo para ler!');
      end;
      //ls: lista o conteúdo do diretório
      'ls':
        //Inicia a busca por um arquivo ou diretório
      begin
        if FindFirst('*', faAnyFile and faDirectory, SR) = 0 then
          repeat
            with SR do
            begin
              //arrumar 
              if (arg1 = 'dirs') then
                if (Attr and faDirectory) = faDirectory then
                begin
                  write(Name + ' ');
                  writeln();
                end;
              if (arg1 = 'valid') then
                if ((Name <> '.') and (Name <> '..')) then
                  write(Name + ' ');
              if (arg1 = 'hidden') then
                if (Attr and faHidden) = faHidden then
                  write(Name + ' ');
              if (arg1 = 'files') then
                if (Attr and faAnyFile) = faAnyFile then
                  write(Name + ' ');
              if (arg1 = 'full') then
              begin
                writeln();
                write(Name + '  ');
                write(Size);
                write('B');
              end;
              if (arg1 = '') then
                write(Name + ' ');
            end;
          until FindNext(SR) <> 0;
        writeln();
        FindClose(SR);
      end;
      //cd: Entra dentro de um diretório
      'cd':
      begin
        //muda para o diretório que foi fornecido pelo usuário
        if (tam1 <> 0) then
          try
            ChDir(str1);
            //caso ocorra um erro
          except
            on E: EInOutError do
              writeln(E.Message);
          end;
        //caso somente seja 'cd', muda para o /home/usuario
        if (tam1 = 0) then
          ChDir('/home/' + GetEnvironmentVariable('USER'));
      end;
      //move: muda o nome do arquivo ou move o arquivo
      'move': if (tam1 <> 0) then
          if (tam2 <> 0) then
            if (promptFile(GetCurrentDir, str2) <> -1) then
              renamefile(str1, str2);
      'copy': if (tam1 <> 0) then
          if (tam2 <> 0) then
            if (promptFile(GetCurrentDir, str2) <> -1) then
              copy(str1, str2);
      //mkfile: cria um novo arquivo
      'mkfile':
      begin
        if (tam1 <> 0) then
          if (promptFile(GetCurrentDir, str1) <> -1) then
            filecreate(str1);
        //caso não seja fornecido um nome
        if (tam1 = 0) then
          writeln('Digite o nome do arquivo para ser criado!');
      end;
      //locate: localiza o arquivo dentro da pasta, todo: recursivo (diretórios)
      'locate':
      begin
        //procura o arquivo com o nome fornecido 
        if (tam1 <> 0) then
          procura(GetCurrentDir, str1);
        //caso o nome do arquivo não for fornecido 
        if (tam1 = 0) then
          writeln('Digite o nome do arquivo!');
      end;
      //rmdir: exclui o diretório com o nome fornecido
      'rmdir':
      begin
        //Tenta excluir o diretório
        try
          if (tam1 <> 0) then
            deletaDir(str1)
          //Caso ocorra algum erro
        except
          on E: EInOutError do
            writeln(E.Message);
        end;
        //Caso o nome não seja fornecido
        if (tam1 = 0) then
          writeln('Digite um diretório para excluir');
      end;
      //rmfile: exclui o arquivo com o nome fornecido
      'rmfile':
      begin
        //Tenta excluir o arquivo 
        try
          if (tam1 <> 0) then
            DeleteFile(str1);
          //Caso ocorra algum erro
        except
          on E: EInOutError do
            writeln(E.Message);
        end;
        //Caso o nome do arquivo não seja fornecido
        if (tam1 = 0) then
          writeln('Digite um arquivo para excluir');
      end;
      //mkdir: cria um novo diretório
      'mkdir':
      begin
        //tenta criar o novo diretório
        try
          if (tam1 <> 0) then
            if (promptDir(GetCurrentDir, str1) <> -1) then
              mkdir(str1);

          //caso ocorra algum erro
        except
          on E: EInOutError do
            writeln(E.Message);
        end;
        //caso o nome do diretório não seja fornecido
        if (tam1 = 0) then
          writeln('Digite um diretório para criar');
      end;
      //clear: limpa a tela
      'clear': clrscr();
        //Caso padrão, não entrou em nenhum caso 
      else writeln('Comando não reconhecido!');
    end;
  end;
end.