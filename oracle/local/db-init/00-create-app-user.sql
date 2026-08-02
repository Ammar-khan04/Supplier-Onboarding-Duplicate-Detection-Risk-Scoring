whenever sqlerror continue
alter session set container = FREEPDB1;
whenever sqlerror exit sql.sqlcode

declare
  l_count number;
begin
  select count(*)
  into l_count
  from dba_users
  where username = 'SUPPLIER_APP';

  if l_count = 0 then
    execute immediate 'create user supplier_app identified by "SupplierApp12345" quota unlimited on users';
  end if;
end;
/

grant create session to supplier_app;
grant create table to supplier_app;
grant create view to supplier_app;
grant create sequence to supplier_app;
grant create procedure to supplier_app;
grant create trigger to supplier_app;
grant create type to supplier_app;
grant create synonym to supplier_app;
grant unlimited tablespace to supplier_app;
