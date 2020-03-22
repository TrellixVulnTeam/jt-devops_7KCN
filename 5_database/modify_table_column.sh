#!/bin/bash
user=root
pass=gzhXR6d@k*42FV

for i in i `seq 1 25`;do
  mysql -u$user -p$pass -e "alter table jtb_log_db$i.CA_TRIP_DISCRETE   modify ID bigint(14);"
  mysql -u$user -p$pass -e "alter table jtb_log_db$i.CA_TRIP_DISCRETE   modify TRIP_ID bigint(14);"
done
