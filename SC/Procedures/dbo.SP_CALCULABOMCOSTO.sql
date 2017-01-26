SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









/* calcula los costos del los subensambles en orden ascendente es decir del 12 al 1 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTO]  (@bst_pt int, @Entravigor datetime, @GuardaHist char(1)='N', @spi_codigo int =22, @user int=1, @tco_codigo int=1)   as

SET NOCOUNT ON 
declare @fecha varchar(10), @ConsCal int, @uservar varchar(50), @bst_ptvar varchar(50), @spi_codigovar varchar(50), @cos_uni varchar(50), @tco_codigovar varchar(50)

SET @Fecha =convert(varchar(10), @Entravigor,101)


	select @uservar= convert(varchar(50),@user)


exec('exec sp_droptable ''TempBOM_NIVEL'+@uservar+'''')
exec('CREATE TABLE [dbo].[TempBOM_NIVEL'+@uservar+'] (
	[BST_PT] [int]  NOT NULL ,
	[BST_PERTENECE] [int] NOT NULL ,
	[BST_HIJO] [int] NULL ,
	[BST_NIVEL] [int] NULL ,
	[BST_PERINI] [datetime] NULL,
	[BST_INCORPOR] decimal(38,6) NULL,
	[BST_INCORPORUSO] decimal(38,6) NULL
) ON [PRIMARY]')



	select @bst_ptvar = convert(varchar(50),@bst_pt), @spi_codigovar= convert(varchar(50),@spi_codigo), @tco_codigovar =convert(varchar(50),@tco_codigo)


	insert into sysusrlog41 (user_id, mov_id, referencia, frmtag, fechahora)
	select 0, 2, ma_noparte+', Recalculo de Costos', 41, getdate()
	from maestro 
	where ma_codigo=@bst_pt


	exec SP_FILL_TempBOMNivelUno @BST_PT, @Fecha, @uservar


/*=============================*/


	exec ('exec sp_droptable ''CalculandoCosto'+@uservar+'''')

	exec ('create table [dbo].[CalculandoCosto'+@uservar+'] (BST_PERTENECE int, BST_PERINI datetime)')


/*=============================*/



	-- el campo bst_tipocosto es temporal, se va a modificar de acuerdo al spi_codigo que se usando en el calculo
	exec SP_ACTUALIZATIPOCOSTOTempBOM_NIVELUno @spi_codigo, @uservar



	exec('if exists (select * from TempBOM_NIVEL'+@uservar+' where bst_pt='+@bst_ptvar+')
	begin
		declare @nivelmax int
		set @nivelmax=1
		
		SELECT     @nivelmax = max (BST_NIVEL)+1
		FROM         TempBOM_NIVEL'+@uservar+'
		WHERE      (BST_PT = '+@bst_ptvar+') 

		  -- se actualizan los <> del nivel maximo menos el pt 
		EXEC SP_CALCULABOMCOSTO2 '+@bst_ptvar+', @nivelmax, '''+@Entravigor+''', '''+@GuardaHist+''', '+@spi_codigovar+', '+@uservar+' ,'+@tco_codigovar+'


		-- se actualiza el pt
		EXEC SP_CALCULABOMCOSTOSUBUno '''+@GuardaHist+''', '+@bst_ptvar+', '+@spi_codigovar+', '+@uservar+' ,'+@tco_codigovar+'

	end')

	

	exec('insert into CalculandoCosto'+@uservar+'(bst_pertenece, bst_perini) values('+@bst_ptvar+', '''+@Entravigor+''')')

	EXEC SP_CALCULABOMCOSTOSUBUno @GuardaHist, @bst_pt, @spi_codigo, @uservar, @tco_codigovar  -- Se actualizan los de nivel maximo, PT 




	if @tco_codigo in (select tco_codigo from tcosto where tco_nombre='COSTO DE RETRABAJO')
	begin

		-- en esta opcion agrega el costo del producto total a la parte no gravable (9802)
		alter table MAESTROCOST disable trigger Insert_MaestroCost 		

		select @cos_uni=convert(varchar(50),m1.ma_costo) from maestrocost m1 where m1.mac_codigo in
					(SELECT MAX(MAC_CODIGO)
					FROM MAESTROCOST
					WHERE SPI_CODIGO = @spi_codigo AND TCO_CODIGO in (select  TCO_MANUFACTURA from configuracion)
					AND ma_perini<=@Entravigor and ma_perfin>=@Entravigor and ma_codigo=@bst_pt
					GROUP BY MA_CODIGO) 


		 exec('UPDATE MAESTROCOST
		SET MA_NG_MP=MA_NG_MP+'+@cos_uni+' 
		FROM   MAESTROCOST
		WHERE   ma_codigo='+@bst_ptvar+' and SPI_CODIGO = '+@spi_codigovar+' and ma_perini<='''+@Entravigor+''' and ma_perfin>='''+@Entravigor+''' 
			and tco_codigo='+@tco_codigovar)


		exec('UPDATE MAESTROCOST
		SET MA_COSTO = round( isnull(MA_GRAV_MP + MA_GRAV_ADD + MA_GRAV_EMP + MA_GRAV_GI + MA_GRAV_GI_MX 
		+ MA_GRAV_MO + MA_NG_MP + MA_NG_ADD + MA_NG_EMP,0),6)
		WHERE mac_codigo in (SELECT MAX(m1.MAC_CODIGO)
					FROM MAESTROCOST m1
					WHERE m1.SPI_CODIGO = '+@spi_codigovar+' AND m1.TCO_CODIGO = '+@tco_codigovar+' 
						and m1.ma_codigo='+@bst_ptvar+' and m1.ma_perini<='''+@Entravigor+''' and m1.ma_perfin>='''+@Entravigor+''' 
					GROUP BY MA_CODIGO)')

		alter table MAESTROCOST enable trigger Insert_MaestroCost 		
	end


	 IF (SELECT CF_USACOSTNODUTNAFTA FROM CONFIGURACION)='S' and @spi_codigo in (select spi_codigo from spi where spi_clave='nafta')
	   begin
		alter table MAESTROCOST disable trigger Insert_MaestroCost 		

		 exec('UPDATE MAESTROCOST
		SET MA_GRAV_MP= MA_GRAV_MP+ MA_GRAV_ADD+ MA_GRAV_EMP+ MA_NG_MP+ MA_NG_ADD+ MA_NG_EMP,
		MA_GRAV_ADD=0, MA_GRAV_EMP=0, MA_NG_MP=0, MA_NG_ADD=0, MA_NG_EMP=0, MA_NG_USA=0
		FROM   MAESTROCOST
		WHERE  TCO_CODIGO IN (SELECT TCO_MANUFACTURA
		                            FROM configuracion) and  SPI_CODIGO = '+@spi_codigovar+' and ma_perini <=getdate() and ma_perfin >= getdate()
		    AND MA_CODIGO IN (SELECT MA_CODIGO FROM NAFTA INNER JOIN SPI ON NAFTA.SPI_CODIGO = SPI.SPI_CODIGO
		                            WHERE SPI.SPI_CLAVE = ''NAFTA'' and NFT_CALIFICO=''S'' AND NAFTA.NFT_PERINI <= '''+@Entravigor+''' AND 
		                                                   NAFTA.NFT_PERFIN >= '''+@Entravigor+''')
		  AND MA_CODIGO IN (SELECT BST_PERTENECE FROM CalculandoCosto'+@uservar+' )')

		alter table MAESTROCOST enable trigger Insert_MaestroCost 		
	  end


	exec ('exec sp_droptable ''CalculandoCosto'+@uservar+'''')
	exec('exec sp_droptable ''TempBOM_NIVEL'+@uservar+'''')





GO
