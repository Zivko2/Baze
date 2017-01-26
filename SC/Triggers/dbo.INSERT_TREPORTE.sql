SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE TRIGGER [INSERT_TREPORTE] ON [dbo].[TREPORTE] 
FOR INSERT
AS
	declare @TRE_NOMBRE varchar(80), @TRE_NOMBRE_RTM varchar(50), @TRE_FRMTAG int
	
	
	SELECT     @TRE_NOMBRE_RTM=TRE_NOMBRE_RTM, @TRE_NOMBRE=TRE_NOMBRE, @TRE_FRMTAG=TRE_FRMTAG
	FROM         Inserted
	
	
	if @TRE_FRMTAG = 183 and @TRE_NOMBRE_RTM not in (select trd_nombre_rtm from treportedesc)
	insert into treportedesc(trd_nombre_rtm, trd_nombre, trd_descripcion)
	values(@TRE_NOMBRE_RTM, @TRE_NOMBRE, @TRE_NOMBRE)































GO
