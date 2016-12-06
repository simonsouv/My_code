-- script to test trace flags 1212 and 1217 giving information about locks used on a SQL statement
use tempdb
go
--check if test table exist
print 'remove existing test tables if any'
go
if exists (select 1 from sysobjects where name = 'simon_allpage' and type = 'U') drop table simon_allpage
go
if exists (select 1 from sysobjects where name = 'simon_datapage' and type = 'U') drop table simon_datapage
go
if exists (select 1 from sysobjects where name = 'simon_datarow' and type = 'U') drop table simon_datarow
go
--create test tables
print 'create test tables'
go

create table simon_allpage (valeur float) lock allpages
create table simon_datapage (valeur float) lock datapages
create table simon_datarow (valeur float) lock datarows
go
--insert test data
print 'insert test data'
go
insert simon_allpage select 1000 * rand()
go 100000
insert simon_datapage select 1000 * rand()
go 100000
insert simon_datarow select 1000 * rand()
go 100000
--get info about the table
select case T1.indid when 0 then convert(char(10),'table')  else convert(char(10),'index') end 'obj type' , T1.id 'obj id', convert(char(30),T2.name) 'obj name', T1.pagecnt 'pages count' 
from systabstats T1 join sysobjects T2 on T1.id = T2.id
where T2.name in ('simon_allpage','simon_datapage','simon_datarow')
go
--enable trace switch
print 'activate trace swith on for 3604, 1212'
go
set switch on 3604
go
set switch on 1217 with override
go
set nodata on
go
-- select test case
print '---- OUTPUT FOR SELECT simon_allpage ----'
go
select * from simon_allpage
go
print '---- OUTPUT FOR SELECT simon_datapage ----'
go
select * from simon_datapage
go
print '---- OUTPUT FOR SELECT simon_datarow ----'
go
select * from simon_datarow
go
-- update test case
print '---- OUTPUT FOR UPDATE simon_allpage ----'
go
update simon_allpage set valeur = valeur * 2
go
print '---- OUTPUT FOR UPDATE simon_datapage ----'
go
update simon_datapage set valeur = valeur * 2
go
print '---- OUTPUT FOR UPDATE simon_datarow ----'
go
update simon_datarow set valeur = valeur * 2
go
--disable trace switch
set switch off 3604
go
set switch off 1217
go
set nodata off
go

