SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[SP_GENERAFACTURAAGRUMASA] (@FECHAINI DATETIME, @FECHAFIN DATETIME, @FECHA DATETIME, @CL_CODIGO INT=0)   as

declare @CL_DESTINI int, @DI_DESTINI int, @folio varchar(25), @fe_folio varchar(25), @CONSECUTIVO int, @Numero int


	IF @CL_CODIGO>0
	begin
		Declare Cur_FactExpAgru cursor for
			SELECT     CL_DESTINI, DI_DESTINI
			FROM         dbo.FACTEXP
			WHERE     (FE_FECHA >= @FECHAINI) AND (FE_FECHA <= @FECHAFIN) AND CL_DESTINI=@CL_CODIGO AND PI_CODIGO=-1
			GROUP BY FE_TIPO, CL_DESTINI, DI_DESTINI
			HAVING      (FE_TIPO = 'V')
	end
	else
	begin
		Declare Cur_FactExpAgru cursor for
			SELECT     CL_DESTINI, DI_DESTINI
			FROM         dbo.FACTEXP
			WHERE     (FE_FECHA >= @FECHAINI) AND (FE_FECHA <= @FECHAFIN)  AND PI_CODIGO=-1
			GROUP BY FE_TIPO, CL_DESTINI, DI_DESTINI
			HAVING      (FE_TIPO = 'V')

	end
		Open Cur_FactExpAgru
		Fetch Next from Cur_FactExpAgru into @CL_DESTINI, @DI_DESTINI
		While (@@fetch_status =0 )
		begin
		
	
		
			SET @folio='VIRT'
		
				if exists (select * from factexpagru where fea_folio like @folio+'%' and fea_folio not like @folio+' %')
				begin
					SELECT @Numero=max(convert(smallint,REPLACE(RIGHT(fea_folio, 5), '_', '')))+1  FROM factexpagru where fea_folio like @folio+'%' and fea_folio not like @folio+' %'

			               SET @fe_folio= @folio+replicate('0', 5-(len(@Numero)))+convert(varchar(50),@Numero)
				end
				else
				       SET @fe_folio= @folio+'00001'
	
	
				 EXEC SP_GETCONSECUTIVO @TIPO='FEA', @VALUE=@CONSECUTIVO OUTPUT
	
				INSERT INTO FACTEXPAGRU(FEA_CODIGO, FEA_FOLIO, FEA_FECHA, TF_CODIGO, TQ_CODIGO, FEA_TIPO, FEA_PINICIAL, FEA_PFINAL, TN_CODIGO, 
				                      AG_MX, AG_US, CL_PROD, DI_PROD, CL_COMP, DI_COMP, CO_COMP, CL_COMPFIN, DI_COMPFIN, CO_COMPFIN, 
				                      CL_EXP, DI_EXP, CL_EXPFIN, DI_EXPFIN, CL_DESTINI, DI_DESTINI, CO_DESTINI, CL_DESTFIN, DI_DESTFIN, CO_DESTFIN, CL_VEND, DI_VEND, 
				                      CL_IMP, DI_IMP, FEA_TOTALB, FEA_TIPOCAMBIO, FEA_ESTATUS)--, AGT_CODIGO)
				
				SELECT     @CONSECUTIVO, @fe_folio, @FECHA, max(TF_CODIGO), max(TQ_CODIGO), max(FE_TIPO), min(FE_PINICIAL), max(FE_PFINAL), max(TN_CODIGO), 
				                      max(AG_MX), max(AG_US), max(CL_PROD), max(DI_PROD), max(CL_COMP), max(DI_COMP), max(CO_COMP), max(CL_COMPFIN), max(DI_COMPFIN), max(CO_COMPFIN), 
				                      max(CL_EXP), max(DI_EXP), max(CL_EXPFIN), max(DI_EXPFIN), CL_DESTINI, DI_DESTINI, max(CO_DESTINI), max(CL_DESTFIN), max(DI_DESTFIN), max(CO_DESTFIN), max(CL_VEND), max(DI_VEND), 
				                      max(CL_IMP), max(DI_IMP), sum(FE_TOTALB), isnull((SELECT TC_CANT FROM TCAMBIO WHERE TC_FECHA=@FECHA),0), 'C'--, max(AGT_CODIGO)
				FROM         FACTEXP
				WHERE     (FE_TIPO = 'V') AND CL_DESTINI=@CL_DESTINI AND DI_DESTINI=@DI_DESTINI
				 AND FE_FECHA >= @FECHAINI AND FE_FECHA <= @FECHAFIN
				group by CL_DESTINI, DI_DESTINI
	
	
				UPDATE FACTEXP
				SET FE_FACTAGRU=@CONSECUTIVO
				FROM         FACTEXP
				WHERE     (FE_TIPO = 'V') AND CL_DESTINI=@CL_DESTINI AND DI_DESTINI=@DI_DESTINI AND PI_CODIGO=-1
				 AND FE_FECHA >= @FECHAINI AND FE_FECHA <= @FECHAFIN
	

			Fetch Next from Cur_FactExpAgru into @CL_DESTINI, @DI_DESTINI
		end
	
	        Close Cur_FactExpAgru
	        Deallocate Cur_FactExpAgru
GO
