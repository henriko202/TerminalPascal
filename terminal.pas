//Projeto 1 FILE CONQUEROR _ Explorador de arquivos com Shell

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

//Main do programa
begin
  // teve que ser feito pois extractword não aceita char
  if (argc=2) then ChDir(argv[1]);
  charset := [];
  include(charset, ' ');
  cArgs := [];
  include(cArgs, '-');
  counter := 1;
  entrada := '';

  //Enquanto não for digitado 'exit'
  while (CompareText(entrada, 'exit') <> 0) do
  begin
    arg0 :='';
    arg1 :='';
    write(GetCurrentDir);
    write('>');
    readln(entrada);

    for i := 0 to length(entrada) do
    begin
      if (entrada[i] = '-') then
       begin
         if (counter=1) then 
         begin
         arg0 := extractword(counter, entrada, cArgs);
           counter:= counter+1;
         end;
         if (counter=2) then
         begin
          arg1 := extractword(counter, entrada, cArgs);
           counter :=1;
         end;
       end;
       if (entrada[i] <> '-') then 
       begin
         if (counter=1) then
         begin
          str0 := ExtractWord(counter, entrada, charset);
           counter:= counter+1;
         end;
         if (counter=2) then
         begin
          str1 := ExtractWord(counter, entrada, charset);
           counter:= counter+1;
         end;
         if (counter=3) then 
         begin
         str2 := ExtractWord(counter, entrada, charset);
           counter := 1
         end;
       end; 
    end;
      //writeln('arg 1' + arg0);
      //writeln('arg 2' + arg1);
      //writeln('str 0' + str0);
      //writeln('str 1' + str1);
      //writeln('str 2' + str2);
    tam1 := WordCount(str1, charset);
    tam2 := WordCount(str2, charset);

    //Identificando o comando digitado pelo usuário
    case str0 of
      //help: lista os comandos existentes
      'help':
      begin
        writeln('Comandos existentes:');
        writeln('man, exit, cat, ls, cd, mv, touch, locate, rmdir, mkdir, rm, clear');
      end;
      //man: mostra o manual do comando fornecido
      'man': case str1 of
          'man': writeln('Mostra um manual sobre o comando fornecido');
          'exit': writeln('Fecha o terminal');
          'cat': writeln('Mostra o conteúdo de um arquivo passado por argumento');
          'ls': writeln('Mostra o conteúdo da pasta atual');
          'cd': writeln('Muda o diretório atual');
          'mv': writeln('Move ou renomeia um arquivo');
          'touch': writeln('Cria um arquivo');
          'locate': writeln('Procura um arquivo na pasta atual');
          'rmdir': writeln('Remove um diretório da pasta autal');
          'mkdir': writeln('Cria um diretório na pasta atual');
          'rm': writeln('Remove um arquivo da pasta atual');
          'clear': writeln('Limpa a tela do terminal');
          'help': writeln('Mostra os comandos existentes');
            // caso padrão, comando vazio ou inexistente
          else
          begin
            //Se comando não for fornecido
            if (tam1 = 0) then
              writeln('Qual manual gostaria de ver?');
            // if then else nao funciona (?????)
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
              if((arg0='d') or (arg1='d')) then
                begin
                  If (Attr and faDirectory) = faDirectory then
                  Write(SR.Name + ' ');
                end;
                if((arg1<>'d') or (arg1<>'d')) then write(SR.Name + ' ');
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
      //mv: muda o nome do arquivo ou move o arquivo
      'mv': if (tam1 <> 0) then
          if (tam2 <> 0) then
            if not (renamefile(str1, str2)) then
              writeln('Erro ao mover arquivo!');
      //touch: cria um novo arquivo
      'touch':
      begin
        if (tam1 <> 0) then
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
        begin
          if FindFirst('*' + str1 + '*', faAnyFile and faDirectory, SR) = 0 then
            repeat
              with SR do
                write(SR.Name + ' ');
            until FindNext(SR) <> 0;
          writeln();
          FindClose(SR);
        end;
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
            rmdir(str1);
          //Caso ocorra algum erro
        except
          on E: EInOutError do
            writeln(E.Message);
        end;
        //Caso o nome não seja fornecido
        if (tam1 = 0) then
          writeln('Digite um diretório para excluir');
      end;
      //rm: exclui o arquivo com o nome fornecido
      'rm':
      begin
        //Tenta excluir o arquivo 
        try
          if (tam1 <> 0) then
          begin
            Assign(texto, str1);
            erase(texto);
          end;
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