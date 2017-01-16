SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.[fillpedimpcont_rect] (@picodigo int, @user int)   as

SET NOCOUNT ON 
declare @PIC_INDICEC int, @maximo int, @hora varchar(15), @FechaActual varchar(10), @em_codigo int

SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Insertando Contenido ', 'Inserting Content (Brands, Serials, etc.)  ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

if exists (select * from pedimpcont where pi_codigo =@picodigo)
delete from pedimpcont where pi_codigo=@picodigo



TRUNCATE TABLE TempPedImpCont

SELECT     @maximo= isnull(MAX(PIC_INDICEC),0)+1
FROM         dbo.PEDIMPCONT

	dbcc checkident (TempPedimpCont, reseed, @maximo) WITH NO_INFOMSGS

	INSERT INTO TempPedImpCont (PI_CODIGO, PID_INDICED, PIC_MARCA, PIC_MODELO, PIC_SERIE, PIC_EQUIPADOCON, PIC_NOACTIVO)
	
	SELECT     @picodigo, dbo.PEDIMPDET.PID_INDICED, dbo.FACTIMPCONT.FIC_MARCA, dbo.FACTIMPCONT.FIC_MODELO, dbo.FACTIMPCONT.FIC_SERIE, 
	                      dbo.FACTIMPCONT.FIC_EQUIPADOCON, dbo.FACTIMPCONT.FIC_NOACTIVO
	FROM         dbo.FACTIMPDET LEFT OUTER JOIN
	                      dbo.PEDIMPDET ON dbo.FACTIMPDET.PID_INDICEDLIGAR1 = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
	                      dbo.FACTIMPCONT ON dbo.FACTIMPDET.FID_INDICED = dbo.FACTIMPCONT.FID_INDICED LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
	WHERE     (dbo.PEDIMPDET.PI_CODIGO=@picodigo) AND (dbo.FACTIMP.PI_RECTIFICA = @picodigo)
	GROUP BY dbo.FACTIMPDET.MA_CODIGO, dbo.FACTIMPDET.FID_NOPARTE, dbo.FACTIMPDET.FID_NOMBRE, dbo.FACTIMPDET.FID_COS_UNI, dbo.FACTIMPDET.FID_PES_UNI, 
	                      dbo.FACTIMPDET.ME_CODIGO, dbo.FACTIMPDET.MA_GENERICO, dbo.FACTIMPDET.EQ_GEN, dbo.FACTIMPDET.EQ_IMPMX, 
	                      dbo.FACTIMPDET.AR_IMPMX, dbo.FACTIMPDET.AR_EXPFO, dbo.FACTIMPDET.FID_RATEEXPFO, dbo.FACTIMPDET.FID_SEC_IMP, 
	                      dbo.FACTIMPDET.FID_DEF_TIP, dbo.FACTIMPDET.FID_POR_DEF, dbo.FACTIMPDET.TI_CODIGO, dbo.FACTIMPDET.PA_CODIGO, 
	                      dbo.FACTIMPDET.SPI_CODIGO, dbo.MAESTRO.PA_PROCEDE, dbo.FACTIMPDET.ME_GEN, dbo.FACTIMPDET.ME_ARIMPMX, 
	                      dbo.FACTIMPCONT.FIC_MARCA, dbo.FACTIMPCONT.FIC_MODELO, dbo.FACTIMPCONT.FIC_SERIE, dbo.FACTIMPCONT.FIC_EQUIPADOCON, 
	                      dbo.PEDIMPDET.PID_INDICED, dbo.FACTIMPCONT.FIC_NOACTIVO


	if exists(select * from factimpdet where cs_codigo=2 and fi_codigo in (select fi_codigo from factimp where pi_codigo=@picodigo)
	and fid_indiced in (select fid_indiced from factimpcontkit))
	begin
		--print 'jo'

		INSERT INTO TempPedImpCont (PI_CODIGO, PID_INDICED, PIC_MARCA, PIC_MODELO, PIC_SERIE)

		SELECT     @picodigo, dbo.PEDIMPDET.PID_INDICED, dbo.FACTIMPCONTKIT.FIK_MARCA, dbo.FACTIMPCONTKIT.FIK_MODELO, 
				dbo.FACTIMPCONTKIT.FIK_SERIE
		FROM         dbo.FACTIMPDET INNER JOIN
		                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
		                      dbo.PEDIMPDET INNER JOIN
		                      dbo.FACTIMPCONTKIT ON dbo.PEDIMPDET.MA_CODIGO = dbo.FACTIMPCONTKIT.MA_CODIGO ON 
		                      dbo.FACTIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO AND dbo.FACTIMPDET.FID_INDICED = dbo.FACTIMPCONTKIT.FID_INDICED
		WHERE     (dbo.PEDIMPDET.PI_CODIGO =@picodigo) and (dbo.PEDIMPDET.PID_INDICED is not null)
			and (dbo.FACTIMPCONTKIT.FIK_MARCA is not null or dbo.FACTIMPCONTKIT.FIK_MODELO is not null or dbo.FACTIMPCONTKIT.FIK_SERIE is not null)
			and dbo.FACTIMPDET.FID_PADREKITINSERT='N'
		GROUP BY dbo.PEDIMPDET.PI_CODIGO, dbo.FACTIMPCONTKIT.FIK_MARCA, dbo.FACTIMPCONTKIT.FIK_MODELO, dbo.FACTIMPCONTKIT.FIK_SERIE, 
		                      dbo.FACTIMPCONTKIT.FID_INDICED, dbo.PEDIMPDET.PID_INDICED

	end



	INSERT INTO PEDIMPCONT (PI_CODIGO, PIC_INDICEC, PID_INDICED, PIC_MARCA, PIC_MODELO, PIC_SERIE, PIC_EQUIPADOCON, PIC_NOACTIVO)

	SELECT     PI_CODIGO, PIC_INDICEC, PID_INDICED, PIC_MARCA, PIC_MODELO, PIC_SERIE, PIC_EQUIPADOCON, PIC_NOACTIVO
	FROM         dbo.TempPedImpCont
	where pi_codigo=@picodigo order by pic_indicec



	
if exists (select * from TempPedImpCont where PI_CODIGO=@picodigo)
delete from  TempPedImpCont where PI_CODIGO=@picodigo



select @Pic_indicec= max(pic_indicec) from pedimpcont

	update consecutivo
	set cv_codigo =  isnull(@pic_indicec,0) + 1
	where cv_tipo = 'PIC'

GO
