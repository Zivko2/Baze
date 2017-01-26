SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_GetTipoDatoDeCampo (@inNombreTabla Varchar(30), @inNombreCampo Varchar(30), @outTipoDato Varchar(25) output)   as
		SELECT     @outTipoDato = type_name(dbo.syscolumns.xtype)
	FROM         dbo.syscolumns INNER JOIN
		dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id
	WHERE     (dbo.sysobjects.type = 'U') AND (dbo.sysobjects.name = @inNombreTabla) AND (dbo.syscolumns.name = @inNombreCampo)

RETURN






GO
