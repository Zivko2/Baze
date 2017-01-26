SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE PROCEDURE [dbo].[SP_INDICES]   as

declare @Constraint varchar(250), @tabla varchar(250), @campo varchar(250), @fillfactor int, @Unique smallint, @Clustered smallint, @Index smallint, @CantCampos smallint,
@enunciado varchar(1100), @columnas varchar(1100), @EnunciadoBorra varchar(1100), @ConstraintNvo varchar(250)

--declare @enunciadofin varchar(8000), @enunciadofin2 varchar(8000) 
set @columnas=''
--set @enunciadofin=''
set @enunciado=''



if exists (select * from sysobjects where name='CREAINDICE_CONTRAINT')
DROP TABLE [CREAINDICE_CONTRAINT]

CREATE TABLE [dbo].[CREAINDICE_CONTRAINT] (
	[IND_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[IND_ENUNCIADO] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IND_NOMBRE] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IND_TABLA] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IND_COLUMNAS] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[IND_UNIQUE] [smallint] NULL ,
	[IND_CLUSTERED] [smallint] NULL ,
	[IND_ENUNCIADOBORRA] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
) ON [PRIMARY]

if exists (select * from sysobjects where name='CREAINDICE_CONTRAINTantes')
DROP TABLE [CREAINDICE_CONTRAINTantes]

CREATE TABLE [dbo].[CREAINDICE_CONTRAINTantes] (
	[Consecutivo] [int] IDENTITY (1, 1) NOT NULL ,
	[Constraint1] [varchar] (800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Tabla] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Campo] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Fillfactor1] [smallint] NULL ,
	[Index1] [smallint] NULL ,
	[CantCampos] [smallint] NULL ,
	[EnunciadoBorra] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
) ON [PRIMARY]


	insert into CREAINDICE_CONTRAINTantes(Constraint1,Tabla, Campo, Fillfactor1, Index1, CantCampos, EnunciadoBorra)
	select  i.name	as  CONSTRAINT_NAME,  lower(t_obj.name) as TABLE_NAME, col.name as COLUMN_NAME,
	      (isnull(i.OrigFillFactor,0)) as FILL_FACTOR, k.keyno AS KEYNO,
		(select max(k2.keyno) from sysindexkeys k2 where k2.indid = k.indid and k2.id = t_obj.id) AS CantCampos,
		'EnunciadoBorra'=CASE WHEN ISNULL(( (INDEXPROPERTY(OBJECT_ID(t_obj.name),i.name,'IsUnique'))),0)=1 then
		'if exists (select name from sysobjects where name ='''+i.name+ ''''  +') ALTER TABLE '+t_obj.name+' DROP CONSTRAINT ['+i.name + '] '
		else
		'if exists (select name from sysindexes where name ='''+i.name+  '''' +') DROP INDEX '+t_obj.name+'.'+i.name + ' '
		 end
	from sysobjects t_obj, syscolumns col,
		master.dbo.spt_values v, sysindexes i, sysindexkeys k
	where t_obj.id	= col.id
	and col.name	= index_col(t_obj.name,i.indid,v.number)
	and t_obj.id	= i.id and ((i.indid = 1 and k.indid = 1) or (i.indid <> 1 and k.indid <> 1))
	and v.type 	= 'P'
	and (i.name LIKE 'IX%' or i.name LIKE 'PK%' or i.name LIKE 'IDX%')
	and k.id = t_obj.id 
	and k.colid = col.colid 
	--and lower(t_obj.name)='actividad'
	order by t_obj.name, i.name, k.keyno



  set @ConstraintNvo=''
	declare AddIndice cursor for
		SELECT     Constraint1, tabla, campo, fillfactor1, max(Index1), max(CantCampos), EnunciadoBorra
		FROM         dbo.CREAINDICE_CONTRAINTantes
		GROUP BY Constraint1, tabla, campo, fillfactor1, EnunciadoBorra
		order by max(Consecutivo)
	
	open AddIndice
		FETCH NEXT FROM AddIndice INTO @Constraint, @tabla, @campo, @fillfactor, @Index, @CantCampos, @EnunciadoBorra
	
		WHILE (@@FETCH_STATUS = 0) 
		begin
	
		   	if @ConstraintNvo=''
			set @ConstraintNvo=@Constraint
	
	
			if @ConstraintNvo=@Constraint
			begin
				select @Unique= ISNULL((SELECT INDEXPROPERTY(OBJECT_ID(@tabla),@Constraint,'IsUnique')),0)
				select @Clustered= ISNULL((SELECT INDEXPROPERTY(OBJECT_ID(@tabla),@Constraint,'IsClustered')),0)
		
				if @Index<>@CantCampos		
			                set @columnas=@columnas+'['+@campo+'],'			
				else
			                set @columnas=@columnas+'['+@campo+']'			
			
		
				if @Index=@CantCampos
				begin
	
					if @Constraint like 'IX%'
					begin
			                   if (@Unique = 1) 
					   begin
			                      if (@fillfactor > 0) 
						begin
						   if @Clustered= 1
			                             set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] unique clustered ('+@columnas+') with fillfactor='+ convert(varchar(10),@FillFactor)+' on [primary] '
						   else
			                             set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] unique nonclustered ('+@columnas+') with fillfactor='+ convert(varchar(10),@FillFactor)+' on [primary] '
		
						end
						else
						begin
						   if @Clustered= 1
			                           set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] unique clustered ('+@columnas+') on [primary] '
						   else
			                           set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] unique nonclustered ('+@columnas+') on [primary] '
						end
					   end
					   else
					   begin
			                     if (@fillfactor > 0) 
					     begin
						   if @Clustered= 1
			                             set @enunciado='create clustered index ['+@Constraint+'] ON ['+@tabla+']('+@columnas+') with fillfactor='+convert(varchar(10),@FillFactor) +' on [primary] '
			 			   else
			                             set @enunciado='create index ['+@Constraint+'] ON ['+@tabla+']('+@columnas+') with fillfactor='+convert(varchar(10),@FillFactor) +' on [primary] '
			                     end
					     else
					     begin
						   if @Clustered= 1
			                             set @enunciado='create clustered index ['+@Constraint+'] ON ['+@tabla+']('+@columnas+') on [primary] '
						   else
			                             set @enunciado='create index ['+@Constraint+'] ON ['+@tabla+']('+@columnas+') on [primary] '
			                     end
					   end
					end
	
	
		
					if @Constraint like 'PK%'
					begin
			                      if (@fillfactor > 0) 
						begin
						   if @Clustered= 1
			                             set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] primary key clustered ('+@columnas+') with fillfactor='+ convert(varchar(10),@FillFactor)+' on [primary] '
						   else
			                             set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] primary key nonclustered ('+@columnas+') with fillfactor='+ convert(varchar(10),@FillFactor)+' on [primary] '
						end
						else
						begin
						   if @Clustered= 1
			                           set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] primary key clustered ('+@columnas+') on [primary] '
						   else
			                           set @enunciado='alter table '+@tabla+ ' with nocheck add constraint ['+@Constraint+'] primary key nonclustered ('+@columnas+') on [primary] '
						end
					 end
		
		
		
		--		   set @enunciadofin = @enunciadofin+@enunciado+'
		--'
		
					insert into CREAINDICE_CONTRAINT(IND_ENUNCIADO, IND_NOMBRE, IND_TABLA, IND_COLUMNAS, IND_UNIQUE, IND_CLUSTERED, IND_ENUNCIADOBORRA)
					values(@enunciado, @Constraint, @tabla, @columnas, @Unique, @Clustered, @EnunciadoBorra)
		
		
				   set @columnas=''
				   set @ConstraintNvo=''
				end
			end
	
	
		FETCH NEXT FROM AddIndice INTO @Constraint, @tabla, @campo, @fillfactor, @Index, @CantCampos, @EnunciadoBorra
	end
	CLOSE AddIndice
	DEALLOCATE AddIndice


	if exists (select * from sysobjects where name='CREAINDICE_CONTRAINTantes')
	DROP TABLE [CREAINDICE_CONTRAINTantes]






























GO
