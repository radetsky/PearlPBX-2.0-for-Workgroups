BEGIN;

DROP TABLE alembic_version;

CREATE TABLE alembic_version (
    version_num VARCHAR(32) NOT NULL
);

-- Running upgrade None -> 210693f3123d

CREATE TABLE cdr (
    calldate timestamp with time zone DEFAULT now() NOT NULL, 
    accountcode VARCHAR(20), 
    src VARCHAR(80), 
    dst VARCHAR(80), 
    dcontext VARCHAR(80), 
    clid VARCHAR(80), 
    channel VARCHAR(80), 
    dstchannel VARCHAR(80), 
    lastapp VARCHAR(80), 
    lastdata VARCHAR(80), 
    start TIMESTAMP WITHOUT TIME ZONE, 
    answer TIMESTAMP WITHOUT TIME ZONE, 
    "end" TIMESTAMP WITHOUT TIME ZONE, 
    duration INTEGER, 
    billsec INTEGER, 
    disposition VARCHAR(45), 
    amaflags VARCHAR(45), 
    userfield VARCHAR(256), 
    uniqueid VARCHAR(150), 
    linkedid VARCHAR(150), 
    peeraccount VARCHAR(20), 
    sequence INTEGER
);

INSERT INTO alembic_version (version_num) VALUES ('210693f3123d');

COMMIT;

create index cdr_src on cdr(src); 
create index cdr_dst on cdr(dst);
create index cdr_disposition on cdr(disposition); 

