CREATE TABLE [dbo].[vote_session_time_restrictions] (
    [restrictionid] [int] IDENTITY(1,1) NOT NULL,
    [sessionid] [int] NOT NULL,
    [start_time] [TIME] NOT NULL,
    [end_time] [TIME] NOT NULL,
    [day_of_week] [int] NOT NULL,
    CONSTRAINT [PK_vote_session_time_restrictions] PRIMARY KEY CLUSTERED ([restrictionid] ASC),
    CONSTRAINT [FK_vote_session_time_restrictions_session] FOREIGN KEY ([sessionid]) REFERENCES [dbo].[vote_sessions]([sessionid])
);