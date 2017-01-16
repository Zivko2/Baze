SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_ACTUALIZAINFOANEXACOMPL] (@pi_codigo int)   as

SET NOCOUNT ON 

			UPDATE PEDIMPDET
			SET     PEDIMPDET.MA_GENERICO= isnull(PEDIMPDETcompl.MA_GENERICO,0),
			PEDIMPDET.EQ_GENERICO = isnull(PEDIMPDETcompl.EQ_GENERICO,1),
			PEDIMPDET.EQ_IMPMX = isnull(PEDIMPDETcompl.EQ_IMPMX,1),
			PEDIMPDET.AR_IMPMX = isnull(PEDIMPDETcompl.AR_IMPMX,0),
			PEDIMPDET.AR_EXPFO = isnull(PEDIMPDETcompl.AR_EXPFO,0),
			PEDIMPDET.PID_RATEEXPFO = isnull(PEDIMPDETcompl.PID_RATEEXPFO,-1),
			PEDIMPDET.PID_POR_DEF = isnull(PEDIMPDETcompl.PID_POR_DEF,-1),
			PEDIMPDET.TI_CODIGO = isnull(PEDIMPDETcompl.TI_CODIGO,0),
			PEDIMPDET.SPI_CODIGO = isnull(PEDIMPDETcompl.SPI_CODIGO,0),
			PEDIMPDET.ME_GENERICO = isnull(PEDIMPDETcompl.ME_GENERICO,0),
			PEDIMPDET.ME_ARIMPMX = isnull(PEDIMPDETcompl.ME_ARIMPMX,0),
			PEDIMPDET.CS_CODIGO = isnull(PEDIMPDETcompl.CS_CODIGO,0),
			PEDIMPDET.SE_CODIGO = isnull(PEDIMPDETcompl.SE_CODIGO,0),
			PEDIMPDET.PID_REGIONFIN = isnull(PEDIMPDETcompl.PID_REGIONFIN,0)
			FROM        PEDIMPDET PEDIMPDETcompl INNER JOIN
			                      PEDIMPDET ON PEDIMPDETcompl.PID_INDICED = PEDIMPDET.PID_INDICEDLIGA
			WHERE     PEDIMPDETcompl.PI_CODIGO = @pi_codigo




			UPDATE dbo.FACTEXPDET
			SET     dbo.FACTEXPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
			dbo.FACTEXPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
			dbo.FACTEXPDET.EQ_EXPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
			dbo.FACTEXPDET.AR_EXPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
			dbo.FACTEXPDET.AR_IMPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
			dbo.FACTEXPDET.FED_RATEIMPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
			dbo.FACTEXPDET.FED_RATEEXPMX = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
			dbo.FACTEXPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
			dbo.FACTEXPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
			dbo.FACTEXPDET.ME_GENERICO = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
			dbo.FACTEXPDET.ME_AREXPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
			dbo.FACTEXPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
			dbo.FACTEXPDET.SE_CODIGO = isnull(dbo.PEDIMPDET.SE_CODIGO,0),
			dbo.FACTEXPDET.FED_DESTNAFTA = isnull(dbo.PEDIMPDET.PID_REGIONFIN,0)
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGAR1
			WHERE     dbo.PEDIMPDET.PI_CODIGO 
				in (select pi_codigo from pedimp where pi_complementa=@pi_codigo and cp_codigo in
				      (select cp_codigo from configuraclaveped where ccp_tipo='RE')) 


			UPDATE dbo.FACTEXPDET
			SET     dbo.FACTEXPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
			dbo.FACTEXPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
			dbo.FACTEXPDET.EQ_EXPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
			dbo.FACTEXPDET.AR_EXPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
			dbo.FACTEXPDET.AR_IMPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
			dbo.FACTEXPDET.FED_RATEIMPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
			dbo.FACTEXPDET.FED_RATEEXPMX = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
			dbo.FACTEXPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
			dbo.FACTEXPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
			dbo.FACTEXPDET.ME_GENERICO = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
			dbo.FACTEXPDET.ME_AREXPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
			dbo.FACTEXPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
			dbo.FACTEXPDET.SE_CODIGO = isnull(dbo.PEDIMPDET.SE_CODIGO,0),
			dbo.FACTEXPDET.FED_DESTNAFTA = isnull(dbo.PEDIMPDET.PID_REGIONFIN,0)
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA
			WHERE     dbo.PEDIMPDET.PI_CODIGO 
				in (select pi_codigo from pedimp where pi_complementa=@pi_codigo and cp_codigo in
				      (select cp_codigo from configuraclaveped where ccp_tipo<>'RE'))






































GO
