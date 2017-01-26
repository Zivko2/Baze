SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE PROCEDURE [dbo].[SP_INVENTARIOFECHA] (@macodigo int, @cft_tipo char(1), @picodigo int, @fecha datetime)   as

SET NOCOUNT ON 
declare @owner varchar(150)


TRUNCATE TABLE INVENTARIOTEMP 

if not exists (select * from dbo.sysobjects where name='INVENTARIOTempFecha')
CREATE TABLE [dbo].[INVENTARIOTempFecha]
		(PI_CODIGO int,
		NoPedimento varchar(50), 
		FechaPedimento datetime, 
		FechaPagoPedimento datetime, 
		PID_saldoCANT decimal(38,6), 
		ME_CORTO varchar(5), 
		PID_SALDOGEN decimal(38,6), 
		ME_GEN varchar(5), 
		PID_COS_UNI decimal(38,6), 
		AR_FRACCION varchar(20), 
		PID_POR_DEF decimal(38,6), 
		MA_CODIGO int, 
		SE_CLAVE varchar(5), 
		SPI_CLAVE varchar(20), 
		TI_CODIGO int, 
		PID_NOPARTE varchar(50),
		PID_DEF_TIP varchar(50))


	TRUNCATE TABLE INVENTARIOTempFecha



if @macodigo<>0
	-- inventario de un numero de parte
	exec SP_INVENTARIOFECHAMA @macodigo, @cft_tipo, @picodigo, @fecha

if @cft_tipo<>''
	-- inventario por tipo de material, Q=equipo y herramientas y R=Materia prima, partes y componentes
	exec SP_INVENTARIOFECHATI @macodigo, @cft_tipo, @picodigo, @fecha

if @picodigo<>0
	-- inventario por pedimento
	exec SP_INVENTARIOFECHAPI @macodigo, @cft_tipo, @picodigo, @fecha



	exec sp_droptable 'INVENTARIOTempFecha'




































GO
