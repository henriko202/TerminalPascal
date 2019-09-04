//Projeto 1 FILE CONQUEROR _ Explorador de arquivos com Shell
//Alunos: Henriko Alberton, Erica Saito

program TTY;

{$MODE OBJFPC}

//Bibliotecas utilizadas
uses
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
  texto: Text;
  option: string;

procedure procura(const diretorio, arquivo: string);
var
  SR: TSearchRec;
  caminho: string;
begin
  caminho := IncludeTrailingBackslash(diretorio);
  if FindFirst(caminho + arquivo, faAnyFile - faDirectory, SR) = 0 then
    try
      repeat
        writeln(caminho + SR.Name);
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
  writeln(caminho + arquivo);
  if FindFirst(caminho + arquivo, faDirectory, SR) = 0 then
  begin
    repeat
      j := j + 1;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if (j = 1) then
  begin
    writeln('Arquivo ou diretório já existente, deseja sobrescrever? [y/n]');
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
  writeln(caminho + arquivo);
  if FindFirst(caminho + arquivo, faAnyFile, SR) = 0 then
  begin
    repeat
      j := j + 1;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if (j = 1) then
  begin
    writeln('Arquivo ou diretório já existente, deseja sobrescrever? [y/n]');
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
      //help: lista os comandos existentes
      'help':
      begin
        writeln('Comandos existentes:');
        writeln('man, exit, cat, ls, cd, move, mkfile, locate, rmdir, mkdir, rmfile, clear, copy');
      end;
      //man: mostra o manual do comando fornecido
      'man': case str1 of
          'man': writeln('Mostra um manual sobre o comando fornecido');
          'exit': writeln('Fecha o terminal');
          'cat': writeln('Mostra o conteúdo de um arquivo passado por argumento');
          'ls': writeln('Mostra o conteúdo da pasta atual');
          'cd': writeln('Muda o diretório atual');
          'move': writeln('Move arquivo ou diretório para destino');
          'mkfile': writeln('Cria um arquivo');
          'locate': writeln('Procura um arquivo na pasta atual');
          'rmdir': writeln('Remove um diretório da pasta autal');
          'mkdir': writeln('Cria um diretório na pasta atual');
          'rmfile': writeln('Remove um arquivo da pasta atual');
          'clear': writeln('Limpa a tela do terminal');
          'help': writeln('Mostra os comandos existentes');
          'copy': writeln('Copia arquivo/diretório para destino');
            // caso padrão, comando vazio ou inexistente
          else
          begin
            //Se comando não for fornecido
            if (tam1 = 0) then
              writeln('Qual manual gostaria de ver?');
            //if then else nao funciona (?????)
            //se comando não existe
            if (tam1 <> 0) then
              writeln('Comando ' + str1 + ' inexistente!');
          end;
        end;
      //exit: sai do terminal 
      'exit':
      begin
        writeln('Bye!');
        exit;
      end;
      'exita':
      begin
        writeln('Exitando');
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
              if ((arg0 = 'd') or (arg1 = 'd')) then
                if (Attr and faDirectory) = faDirectory then
                  write(SR.Name + ' ');
            if ((arg1 <> 'd') or (arg1 <> 'd')) then
              write(SR.Name + ' ');
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
            begin
              renamefile(str1, str2)

            end;
      //mkfile: cria um novo arquivo
      'mkfile':
      begin
        if (tam1 <> 0) then
          if (promptFile(GetCurrentDir, str1) <> -1) then filecreate(str1);
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
          if (tam1 <> 0) then DeleteFile(str1);
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