SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[SP_IMPORTVERIFICAPO_FI] (@tabla varchar(150), @ims_cbforma int, @Insert char(1))   as

declare @FI_TIPO char(1), @FID_INDICED int, @CANTSALDO2 decimal(38,6), @CANTSALDO decimal(38,6), @FID_CANT_ST decimal(38,6),
@FID_NOPARTE varchar(30), @FID_ORD_COMP varchar(25), @cantRest decimal(38,6)

	if @ims_cbforma=21 and @Insert='S'
	begin

		DECLARE CUR_VERIFICAPO CURSOR FOR
		
				SELECT FI_TIPO, FID_INDICED, isnull(FID_CANT_ST,0), FID_NOPARTE, FID_ORD_COMP
				FROM    FACTIMPDET INNER JOIN
				                      FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
				WHERE (FID_CANT_ST>0) AND (FID_CANT_ST IS NOT NULL)
				AND FACTIMP.FI_FOLIO IN (SELECT REPLACE(LEFT(RI_REGISTRO,CHARINDEX(',',RI_REGISTRO)-1),'FI_FOLIO = ','') 
							FROM REGISTROSIMPORTADOS
							WHERE RI_REGISTRO LIKE 'FI_FOLIO%' AND RI_TIPO='I')
				and FACTIMP.fi_estatus not in ('A', 'C', 'L') and FACTIMP.fi_iniciocruce<>'S'
				and FACTIMP.TQ_CODIGO NOT IN (SELECT TQ_CODIGO FROM TEMBARQUE WHERE TQ_NOMBRE='TODO TIPO MATERIAL Y EQUIPO (CASO ESPECIAL)')
		
		open CUR_VERIFICAPO
		
		
			FETCH NEXT FROM CUR_VERIFICAPO INTO @FI_TIPO, @FID_INDICED, @FID_CANT_ST, @FID_NOPARTE, @FID_ORD_COMP
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				set @CANTSALDO2=0
				set @CANTSALDO =0
				set @cantRest=0

				if @FI_TIPO ='V' -- ord. cerradas y abiertas
				begin	
					select @CANTSALDO=isnull((SELECT     sum(SaldoQty)
					FROM   TempOrdCompAbiertas
					WHERE  ContractNbr =@FID_ORD_COMP and ItemNbr=@FID_NOPARTE),0)

					select @CANTSALDO2=isnull((SELECT     sum(SaldoQty)
					FROM   TempOrdCompcerradas
					WHERE  ORDER_NUMBER =@FID_ORD_COMP and ITEM_NUMBER=@FID_NOPARTE),0)


					IF @CANTSALDO+@CANTSALDO2 < @FID_CANT_ST
					begin
						insert into REGISTROSIMPORTADOS(ri_registro, ri_tipo, ri_cbforma)	
						SELECT 'NO SE PUDO IMPORTAR EL NUMERO DE PARTE: '+@FID_NOPARTE+', ORD. COMPRA: '+@FID_ORD_COMP+' SALDO INSUFICIENTE, SALDO:'+CONVERT(VARCHAR(50),@CANTSALDO)
						+' CANTIDAD A IMPORTAR: '+CONVERT(VARCHAR(50),@FID_CANT_ST), 'I', 21		
	
	
						DELETE FROM FACTIMPDET WHERE FID_INDICED=@FID_INDICED
					end
					else
					begin
						if @CANTSALDO2 >  0 
						update TempOrdCompcerradas
						set SaldoQty=SaldoQty-@FID_CANT_ST
						WHERE  ORDER_NUMBER =@FID_ORD_COMP and ITEM_NUMBER=@FID_NOPARTE
				
						if @FID_CANT_ST> @CANTSALDO2
						set @cantRest=@FID_CANT_ST-@CANTSALDO2

						if @cantRest >0
						update TempOrdCompAbiertas
						set SaldoQty=SaldoQty-@cantRest
						WHERE  ContractNbr =@FID_ORD_COMP and ItemNbr=@FID_NOPARTE

					end
				end
				else
				begin

					select @CANTSALDO=isnull((SELECT     sum(SaldoQty)
					FROM   TempOrdCompAbiertas
					WHERE  ContractNbr =@FID_ORD_COMP and ItemNbr=@FID_NOPARTE),0)


					IF @CANTSALDO< @FID_CANT_ST
					begin
						insert into REGISTROSIMPORTADOS(ri_registro, ri_tipo, ri_cbforma)	
						SELECT 'NO SE PUDO IMPORTAR EL NUMERO DE PARTE: '+@FID_NOPARTE+', ORD. COMPRA: '+@FID_ORD_COMP+' SALDO INSUFICIENTE, SALDO:'+CONVERT(VARCHAR(50),@CANTSALDO)
						+' CANTIDAD A IMPORTAR: '+CONVERT(VARCHAR(50),@FID_CANT_ST), 'I', 21		
	
	
						DELETE FROM FACTIMPDET WHERE FID_INDICED=@FID_INDICED
					end
					else
					begin
						if @FID_CANT_ST >0
						update TempOrdCompAbiertas
						set SaldoQty=SaldoQty-@FID_CANT_ST
						WHERE  ContractNbr =@FID_ORD_COMP and ItemNbr=@FID_NOPARTE

					end
					
					
				end
		
			FETCH NEXT FROM CUR_VERIFICAPO INTO @FI_TIPO, @FID_INDICED, @FID_CANT_ST, @FID_NOPARTE, @FID_ORD_COMP
		
		END
		
		CLOSE CUR_VERIFICAPO
		DEALLOCATE CUR_VERIFICAPO




	end





GO
