-- Create Table Private_AssertEqualsTableSchema_Expected
Print 'Create Table Private_AssertEqualsTableSchema_Expected'
GO
CREATE TABLE [tSQLt].[Private_AssertEqualsTableSchema_Expected] (
		[name]                [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RANK(column_id)]     [int] NULL,
		[system_type_id]      ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[user_type_id]        ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[max_length]          [smallint] NULL,
		[precision]           [tinyint] NULL,
		[scale]               [tinyint] NULL,
		[collation_name]      [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[is_nullable]         [bit] NULL,
		[is_identity]         [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
