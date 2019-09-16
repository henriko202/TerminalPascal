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
  com: TStringList;
  arg: TStringList;
  tam1: integer;
  tam2: integer;
  charset: TSysCharSet;
  cArgs: TSysCharSet;
  arq: TextFile;
  outputString: string;
  SR: TSearchRec;
  sorted: TStringList;
  verifica: string;

//Para copiar um arquivo de um lugar para o outro, utilizando um buffer de memória
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

//Função criara para escrever na mesma linha, já que o sorted.text escrevia em varias linhas
procedure escreve(sorted: TStringList);
var
  i: integer;
begin
  for i := 0 to sorted.Count - 1 do
    write(sorted[i] + ' ');
  writeln();
end;

//Procura de forma recursiva, caso achar um diretório é chamado a mesma função novamente (por isso recursão)
procedure procura(const diretorio, arquivo: string);
var
  SR: TSearchRec;
  caminho: string;
begin
  caminho := IncludeTrailingBackslash(diretorio);
  if FindFirst(caminho + arquivo, faAnyFile, SR) = 0 then
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

//Para deletar um diretório, primeiro acha ele, caso existir arquivos exclua todos e então exclua o diretório
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

//Ao criar um diretório, caso já exista é pedido se quer reescrever, se sim, exclua o diretório e o crie novamente
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

//Mesma coisa que o de cima, porém com arquivos
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
  if (argc = 2) then
    ChDir(argv[1]);
  //Teve que ser feito pois extractword não aceita charcharset := [];
  include(charset, ' ');
  cArgs := [];
  include(cArgs, '-');
  entrada := '';
  //Enquanto não for digitado 'exit'
  while (CompareText(entrada, 'exit') <> 0) do
  begin
    counter := 0;
    com := TStringList.Create;
    arg := TStringList.Create;
    tam1 := 0;
    tam2 := 0;
    write('user@terminal:');
    write(GetCurrentDir);
    write('>');
    readln(entrada);

	//Esse for vai contar a quantidade de palavras
    for i := 0 to length(entrada) do
    begin
      if (length(entrada) = 0) then
        break;
      if (entrada[i] = ' ') then
        counter := counter + 1;
    end;
    //Adicionar palavras no com
    for i := 0 to counter do
    begin
      com.add(ExtractWord(i + 1, entrada, charset));
      if (com[i] = ' ') then
        com.Delete(i);
    end;
	//Caso a palavra comece com "-" adicionar em arg
    for i := 0 to com.Count - 1 do
    begin
      verifica := com[i];
      if (pos('-', verifica) = 1) then
        arg.add(com[i]);
    end;
    //Removendo as palavras que começam com "-" de com
    for i := com.Count - 1 downto 0 do
    begin
      verifica := com[i];
      if (pos('-', verifica) = 1) then
        com.Delete(i);
    end;
	//Adicionando palavras vazias em com e arg, para não dar erros
    if (arg.Count < 2) then
      for i := arg.Count + 1 to 2 do
        arg.add('');
    if (com.Count < 3) then
      for i := com.Count to 2 do
        com.add('');
	//Se a gente não tivesse adicionado palavras vazias, daria erro aqui
    tam1 := length(com[1]);
    tam2 := length(com[2]);
    //Identificando o comando digitado pelo usuário
    case com[0] of
      //man: mostra o manual do comando fornecido
      'man': case com[1] of
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
            writeln(
              'Ou pode ser passado o argumento -full (sozinho) que irá mostrar todas as informaçoes dos arquivos e pastas');
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
          'copy':
          begin
            writeln('Copia arquivo/diretório para destino');
            writeln('Sinopsys: copy [source] [target]');
          end;
            // caso padrão, comando inexistente ou mostra os comandos disponíveis
          else if (com[1] = '') then
            begin
              writeln('Comandos existentes:');
              writeln('ls, cd, mkdir, mkfile, rmdir, rmfile, move, copy, clear, man, locate, cat');
              writeln('ls possui certos argumentos, consulte "man ls" para vê-los');
            end
            //se comando não existe
            else
              writeln('Comando ' + com[1] + ' inexistente!');
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
        AssignFile(arq, com[1]);
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
        sorted := TStringList.Create;
        if FindFirst('*', faAnyFile, SR) = 0 then
          repeat
            with SR do
            begin
              //Temos uma grande gama de ifs em nosso código, escolha o seu!
              //Cada if é um argumento do ls, o if aninhado é para verificar
              //se é um arquivo, um diretório, etc.
              if (arg[0] = '-dirs') then
                if (Attr and faDirectory) = faDirectory then
                  sorted.add(Name);
              if (arg[0] = '-valid') then
                if ((Name <> '.')) then
                  if ((Name <> '..')) then
                    if ((Attr and faHidden) <> faHidden) then
                      sorted.add(Name);
              if (arg[0] = '-hidden') then
                if ((Attr and faHidden) = faHidden) then
                  sorted.add(Name);
              if (arg[0] = '-files') then
                if ((Attr and faDirectory) <> faDirectory) then
                  sorted.add(Name);
              if (arg[0] = '-full') then
                writeln(Name + '  ' + IntToStr(Size) + 'B');
              if ((arg[0] = '') or (arg[0] = '-sortdesc') or (arg[0] = '-sortasc')) then
                sorted.add(Name);
            end;
          until FindNext(SR) <> 0;
          //Caso algum arugmento seja sortasc ou sortdesc, é ordenado corretamente
        if ((arg[0] = '-sortasc') or (arg[1] = '-sortasc')) then
        begin
          sorted.sort;
          escreve(sorted);
        end
        else if ((arg[0] = '-sortdesc') or (arg[1] = '-sortdesc')) then
        begin
          sorted.sort;
          for i := sorted.Count - 1 downto 0 do
            write(sorted[i] + ' ');
          writeln();
        end
        //Caso nenhuma ordenação seja requirida, é apenas escrito na tela
        else if ((arg[0] = '') or (arg[1] = '')) then
          escreve(sorted);
        FindClose(SR);
        sorted.Free;
      end;
      //cd: Entra dentro de um diretório
      'cd':
      begin
        //muda para o diretório que foi fornecido pelo usuário
        if (tam1 <> 0) then
          try
            ChDir(com[1]);
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
            if (promptFile(GetCurrentDir, com[2]) <> -1) then
              renamefile(com[1], com[2]);
      'copy': if (tam1 <> 0) then
          if (tam2 <> 0) then
            if (promptFile(GetCurrentDir, com[2]) <> -1) then
              copy(com[1], com[2]);
      //mkfile: cria um novo arquivo
      'mkfile':
      begin
        if (tam1 <> 0) then
          if (promptFile(GetCurrentDir, com[1]) <> -1) then
            filecreate(com[1]);
        //caso não seja fornecido um nome
        if (tam1 = 0) then
          writeln('Digite o nome do arquivo para ser criado!');
      end;
      //locate: localiza o arquivo dentro da pasta, todo: recursivo (diretórios)
      'locate':
      begin
        //procura o arquivo com o nome fornecido
        if (tam1 <> 0) then
          procura(GetCurrentDir, com[1]);
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
            deletaDir(com[1])
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
            DeleteFile(com[1]);
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
            if (promptDir(GetCurrentDir, com[1]) <> -1) then
              mkdir(com[1]);

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
    //Clear é recomendado para ser utilizado ao invés de Destroy
    com.Clear;
    arg.Clear;
  end;
end.

