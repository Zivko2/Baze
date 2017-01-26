SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedimpdetPerm] (@picodigo int)   as

SET NOCOUNT ON 
declare @maximo INT, @pip_indice int


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TempPedImpDetPerm]') and OBJECTPROPERTY(id, N'IsTable') = 1)
CREATE TABLE [dbo].[TempPedImpDetPerm](
	[PIP_INDICE] [int] IDENTITY(1,1) NOT NULL,
	[PIB_INDICEB] [int] NOT NULL,
	[PI_CODIGO] [int] NOT NULL,
	[IDE_CODIGO] [int] NULL,
	[PE_CODIGO] [int] NOT NULL,
	[PIP_FOLIO] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPedImpDetPerm_PIP_FOLIO]  DEFAULT (''),
	[PIP_FIRMA] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempPedImpDetPerm_PIP_FIRMA]  DEFAULT (''),
	[PIP_VALOR] decimal(38,6) NULL,
	[PIP_CANT] decimal(38,6) NULL
) ON [PRIMARY]

		TRUNCATE TABLE TempPedImpDetPerm


		/*if exists (select * from PedImpDetPerm where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'C1' and IDE_IDENTPERM='P'))
		begin
			delete from  PedImpDetPerm where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo) and IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'C1' and IDE_IDENTPERM='P')
		end*/



		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pib_indiceb'  AND  type = 'U')
		begin
			drop table ##pib_indiceb
		end


		select pib_indiceb 
		INTO ##pib_indiceb
		from pedimpdet where pi_codigo=@picodigo

		delete from  PedImpDetPerm where pib_indiceb in (select pib_indiceb from ##pib_indiceb)
		
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##pib_indiceb'  AND  type = 'U')
		begin
			drop table ##pib_indiceb
		end




		SELECT     @maximo= isnull(MAX(PIP_INDICE),0)+1
		FROM         PEDIMPDETPERM
	
	
		dbcc checkident (TempPedImpDetPerm, reseed, @maximo) WITH NO_INFOMSGS
	


		INSERT INTO TempPedImpDetPerm(PIB_INDICEB, PI_CODIGO, IDE_CODIGO, PE_CODIGO, PIP_FOLIO, PIP_VALOR, PIP_CANT)
		
		
		SELECT     dbo.PEDIMPDET.PIB_INDICEB, dbo.FACTIMP.PI_CODIGO, dbo.PERMISO.IDE_CODIGO, dbo.PERMISO.PE_CODIGO, dbo.PERMISO.PE_FOLIO, sum(dbo.FACTIMPPERM.FIP_VALOR), sum(dbo.FACTIMPPERM.FIP_CANT)
		FROM         dbo.FACTIMPPERM INNER JOIN
		                      dbo.PERMISO ON dbo.FACTIMPPERM.PE_CODIGO = dbo.PERMISO.PE_CODIGO INNER JOIN
		                      dbo.FACTIMP ON dbo.FACTIMPPERM.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMPPERM.FID_INDICED = dbo.FACTIMPDET.FID_INDICED INNER JOIN
		                      dbo.PEDIMPDET ON dbo.FACTIMPDET.PID_INDICEDLIGA = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
		                      dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO
		WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo OR dbo.FACTIMP.PI_RECTIFICA = @picodigo) AND (dbo.IDENTIFICA.IDE_CLAVE IN ('C1')) 
		GROUP BY dbo.FACTIMP.PI_CODIGO, dbo.PERMISO.IDE_CODIGO, dbo.PERMISO.PE_FOLIO, 
		                      dbo.PEDIMPDET.PIB_INDICEB,  dbo.PERMISO.PE_CODIGO
	
			


		insert into PedImpDetPerm (PIP_INDICE, PIB_INDICEB, PI_CODIGO, IDE_CODIGO, PE_CODIGO, PIP_FOLIO, PIP_FIRMA, PIP_VALOR, PIP_CANT)
	
		SELECT     PIP_INDICE, PIB_INDICEB, PI_CODIGO, IDE_CODIGO, PE_CODIGO, PIP_FOLIO, PIP_FIRMA, round(sum(PIP_VALOR),6), round(sum(PIP_CANT),6)
		FROM         TempPedImpDetPerm	
		WHERE PI_CODIGO= @picodigo
		GROUP BY PIP_INDICE, PIB_INDICEB, PI_CODIGO, IDE_CODIGO, PE_CODIGO, PIP_FOLIO, PIP_FIRMA
		





select @pip_indice= isnull(max(pip_indice),0) from PEDIMPDETPERM

	update consecutivo
	set cv_codigo =  isnull(@pip_indice,0) + 1
	where cv_tipo = 'PIP'
GO
