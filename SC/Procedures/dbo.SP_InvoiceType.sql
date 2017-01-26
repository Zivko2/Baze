SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_InvoiceType(@tf_tipo varchar(1))   as


SELECT     TF_CODIGO, TF_NOMBRE, TF_NAME, TF_TIPO
FROM         VTFACTURAENT
where   tf_tipo = case when @tf_tipo = 'F' then 'I' else @tf_tipo end or
        tf_tipo = case when @tf_tipo = 'F' then 'A' else @tf_tipo end





GO
