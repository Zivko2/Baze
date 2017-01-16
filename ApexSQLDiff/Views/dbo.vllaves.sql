SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW dbo.vllaves
with encryption as
 select
	db_name()				as CONSTRAINT_CATALOG
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,c_obj.name				as CONSTRAINT_NAME
	,db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
	,col.name				as COLUMN_NAME
	,col.colid				as ORDINAL_POSITION
from
	sysobjects	c_obj
	,sysobjects	t_obj
	,syscolumns	col
	,sysreferences  ref
where
	c_obj.uid   = user_id()
	and c_obj.xtype	in ('F ')
	and t_obj.id	= c_obj.parent_obj
	and t_obj.id	= col.id
	and col.colid   in 
	(ref.fkey1,ref.fkey2,ref.fkey3,ref.fkey4,ref.fkey5,ref.fkey6,
	ref.fkey7,ref.fkey8,ref.fkey9,ref.fkey10,ref.fkey11,ref.fkey12,
	ref.fkey13,ref.fkey14,ref.fkey15,ref.fkey16)
	and c_obj.id	= ref.constid
union
 select
	db_name()				as CONSTRAINT_CATALOG
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,i.name					as CONSTRAINT_NAME
	,db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
	,col.name				as COLUMN_NAME
	,col.colid				as ORDINAL_POSITION
from
	sysobjects		c_obj
	,sysobjects		t_obj
	,syscolumns		col
	,master.dbo.spt_values 	v
	,sysindexes		i
where
	c_obj.uid	= user_id()
	and c_obj.xtype	in ('UQ' ,'PK')
	and t_obj.id	= c_obj.parent_obj
	and t_obj.xtype  = 'U'
	and t_obj.id	= col.id
	and col.name	= index_col(t_obj.name,i.indid,v.number)
	and t_obj.id	= i.id
	and c_obj.name  = i.name
	and v.number 	> 0 
 	and v.number 	<= i.keycnt 
 	and v.type 	= 'P'














GO
