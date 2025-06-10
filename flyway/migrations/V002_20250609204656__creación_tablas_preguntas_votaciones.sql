CREATE TABLE [dbo].[vote_question_types]
(
[question_typeid] [smallint] NOT NULL IDENTITY(1, 1),
[description] [varchar] (50) NOT NULL
)
GO
ALTER TABLE [dbo].[vote_question_types] ADD CONSTRAINT [PK__vote_que__7C8ECCC76EC598A8] PRIMARY KEY CLUSTERED ([question_typeid])
GO

CREATE TABLE [dbo].[vote_questions]
(
[questionid] [int] NOT NULL IDENTITY(1, 1),
[description] [varchar] (200) NOT NULL,
[required] [bit] NOT NULL,
[max_answers] [smallint] NOT NULL,
[createDate] [datetime] NOT NULL,
[updateDate] [datetime] NULL,
[question_typeid] [smallint] NOT NULL,
[sessionid] [int] NOT NULL
)
GO
ALTER TABLE [dbo].[vote_questions] ADD CONSTRAINT [PK__vote_que__62C2216A04B9E193] PRIMARY KEY CLUSTERED ([questionid])
GO
ALTER TABLE [dbo].[vote_questions] ADD CONSTRAINT [FK_vote_questions.question_typeid] FOREIGN KEY ([question_typeid]) REFERENCES [dbo].[vote_question_types] ([question_typeid])
GO
ALTER TABLE [dbo].[vote_questions] ADD CONSTRAINT [FK_vote_questions.sessionid] FOREIGN KEY ([sessionid]) REFERENCES [dbo].[vote_sessions] ([sessionid])
GO

CREATE TABLE [dbo].[vote_options]
(
[optionid] [tinyint] NOT NULL IDENTITY(1, 1),
[description] [varchar] (200) NOT NULL,
[value] [varchar] (100) NOT NULL,
[url] [varchar] (250) NOT NULL,
[order] [tinyint] NOT NULL,
[checksum] [varbinary] (255) NOT NULL,
[createDate] [datetime] NOT NULL,
[updateDate] [datetime] NULL,
[questionid] [int] NOT NULL
)
GO
ALTER TABLE [dbo].[vote_options] ADD CONSTRAINT [PK__vote_opt__3D42F6398E28D024] PRIMARY KEY CLUSTERED ([optionid])
GO
ALTER TABLE [dbo].[vote_options] ADD CONSTRAINT [FK_vote_options.questionid] FOREIGN KEY ([questionid]) REFERENCES [dbo].[vote_questions] ([questionid])
GO