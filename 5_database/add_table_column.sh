#!/bin/bash
user=root
pass=gzhXR6d@k*42FV

for i in `seq 1 25`;do
  mysql -u$user -p$pass -e "alter table jtb_log_db${i}.CA_VEHICLE_ALARM  add RULE_TYPE  varchar(32);"
  mysql -u$user -p$pass -e "alter table jtb_log_db${i}.CA_VEHICLE_ALARM  add RULE_CONTENT  varchar(2048);"
done
