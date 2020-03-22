#!/bin/bash
IP=`ifconfig eth0|awk 'NR==2{print $2}'`
RESULT=`kubectl get pods -o wide |awk '/^jt/{print $3}'`
LOG=/data/jtb/logs/check_k8spod.log
TIME=`date +'%F %R'`
MAILTO="15071244227@163.com"


kubectl get pods -o wide |awk '{print $1,$2,$3,$4,$5,$6,$7}'|column -t  >${LOG}

set_html () {
cat > .podhtml  <<EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="generator" content="SQL*Plus 11.2.0">
<style type='text/css'> body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} p {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} table,tr,td {font:10pt Arial,Helvetica,sans-serif; color:Black; background:#f7f7e7; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} th {font:bold 10pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} h1 {font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;-
} h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}</style><title>SQL*Plus Report</title>
</head>
<body>
<p>
EOF
}

checkpod_html () {
 file=$1
if [  -f $file   ];then
  tmp=0
  echo "<table border='1' width='90%' align='center' summary='Script output'>" >> .podhtml
  while read line
  do
  echo "<tr>" >>.podhtml
   tmp=$(($tmp+1))
  if [  $tmp -eq 1 ];then
     echo $line|awk '{for(i=1;i<=NF;i++)
       {
             print "<th scope=\"col\">"$i"</th>";
       }     
                     }' >>.podhtml
  else
     echo $line|awk '{for(i=1;i<=NF;i++)
          {
               print "<td align=\"left\">"$i"</td>";
         }  }' >>.podhtml
  fi
     echo "</tr>" >>.podhtml
  done<$file
  echo '</table>'>> .podhtml
  echo '<p></p>'>> .podhtml
else
  echo "$file is not exits" >> .podhtml
  return 1
fi
}

set_html  && \
checkpod_html ${LOG}

echo -e "This mail from 112.35.6.145\n`cat .podhtml`"  |mail -s "$(echo -e "Schdule Check Service\nContent-Type: text/html")" ${MAILTO}
rm -f ${LOG}
