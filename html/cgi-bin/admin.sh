#!/bin/bash

source common.sh

#o contest é valido, tem que verificar o login
if verifica-login admin| grep -q Nao; then
  tela-login admin
fi

#ok logados
LOGIN=$(pega-login)
NOME="$(pega-nome admin)"
TMP=$(mktemp)
POST=$TMP
cat > $TMP
if [[ "x$(< $TMP)" != "x" ]]; then
  FILENAME="$(grep -a 'filename'  "$POST" |sed -e 's/.*filename="\(.*\)".*/\1/g')"
  fd='Content-Type: '
  boundary="$(head -n1 "$POST")"
  INICIO=$(cat -n $TMP| grep -a Content-Type|awk '{print $1}')
  ((INICIO++))
  sed -i  -e "1,${INICIO}d" $TMP
  chmod a+r "$TMP"
  cp $TMP $SUBMISSIONDIR/admin:$LOGIN:$FILENAME
fi
rm $TMP

cabecalho-html
printf "<h1>Administrador $NOME</h1>\n"

printf "<h2>Baixe o contest template</h2>\n"
printf "<p> <a href=\"$BASEURL/contests/sample.tar.bz2\">AQUI</a></h1>\n"
printf "<h3>Formato do arquivo contest-description.txt</h3>"
cat << EOF
<table border=1>
<tr><td>CONTEST_ID</td><td>ID do contest em um nome padrao UNIX, sem espaco</td></tr>
<tr><td>"Nome Completo do Contest"</td><td>Nome completo do contest para
aparecer na tela inicial, deve ser escrito com ASPAS</td></tr>
<tr><td>INICIO-da-prova</td><td>Inicio da prova em segundos, no padrão UNIX gere com
o comando date, por exemplo, se a prova deve começar às 15:00 de hoje:
<br/>
<pre>
date --date="15:00:00 today" +%sh
</pre></td></tr>
<tr><td>TERMINO-da-prova</td><td>Termino da prova em segundos, gere com o
comando date, por exemplo, se a prova deve terminar hoje às 17:00:<br/>
<pre> date --date="17:00:00 today" +%s</pre></tr></td>
<tr><td>N</td><td>Numero inteiro com a quantidade de problemas
da prova, depois serão N linhas com as descrições dos problemas</td></tr>
<tr><td>SITE ID "Nome Completo" Nome_Pequeno link-enunciado</td><td>
N linhas com esse formato, onde cada elemento representa:
<ul>
  <li>SITE: pode ser spoj-br spoj-www uri</li>
  <li>ID: é o ID do problema no SITE</li>
  <li>"Nome completo": nome full do problema, entre ASPAS</li>
  <li>Nome_pequeno: pode ser Letra ou numero mas coloque em ordem nesse
  arquivo</li>
  <li>link-enunciado: pode ser:
    <ul>
      <li> site , redireciona pro SITE</li>
      <li>um link inicando por http://</li>
      <li>none para nao ter um enunciado</li>
      <li>o nome de um arquivo dentro do diretorio enunciados/</li>
    </ul>
  </li>
</ul></td></tr>
<tr><td>M</td><td>Número Inteiro representando a quantidade de usuários
cadastrados</td></tr>
<tr><td>login:senha:Nome Completo</td><td>M linhas com os usuarios que tem
permissão de logar nesse contest</td></tr>
</table>
EOF

echo "<br/><br/>"
printf "<h2>Envie o novo contest</h2>"

cat << EOF
<p> Reenviar um contest já existente irá recriá-lo sem perder as submissões
</p>
<form enctype="multipart/form-data" action="$BASEURL/cgi-bin/admin.sh" method="post">
  <input type="hidden" name="MAX_FILE_SIZE" value="30000">
  File: <input name="myfile" type="file">
  <br/>
  <input type="submit" value="Submit">
  <br/>
</form>
EOF
cat ../footer.html

exit 0
