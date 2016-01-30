#!/bin/bash

cp /etc/postgresql/9.4/main/pg_hba.conf /tmp/pg_hba.conf 
cat /tmp/pg_hba.conf | sed 's/ident$/trust/' >/etc/postgresql/9.4/main/pg_hba.conf
rm /tmp/pg_hba.conf
cp  /etc/postgresql/9.4/main/pg_hba.conf /tmp/pg_hba.conf 
cat /tmp/pg_hba.conf | sed 's/peer$/trust/' >/etc/postgresql/9.4/main/pg_hba.conf
systemctl restart postgresql
psql -U postgres -f /etc/NetSDS/sql/create_user_asterisk.sql
createdb -U postgres asterisk -O asterisk
psql -U asterisk -f /etc/NetSDS/sql/postgresql_config.sql 
psql -U asterisk -f /etc/NetSDS/sql/postgresql_cdr.sql 
psql -U asterisk -f /etc/NetSDS/sql/postgresql_voicemail.sql 
psql -U asterisk -f /etc/NetSDS/sql/pearlpbx.sql 
psql -U asterisk -f /etc/NetSDS/sql/callback.sql
psql -U asterisk -f /etc/NetSDS/sql/directions_list.sql
psql -U asterisk -f /etc/NetSDS/sql/directions.sql
psql -U asterisk -f /etc/NetSDS/sql/sip_conf.sql
psql -U asterisk -f /etc/NetSDS/sql/extensions_conf.sql
psql -U asterisk -f /etc/NetSDS/sql/route.sql
psql -U asterisk -f /etc/NetSDS/sql/local_route.sql
psql -U asterisk -f /etc/NetSDS/sql/cal.sql
psql -U asterisk -f /etc/NetSDS/sql/ivr.sql

