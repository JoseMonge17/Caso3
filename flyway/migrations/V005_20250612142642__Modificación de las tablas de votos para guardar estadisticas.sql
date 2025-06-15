DROP TABLE IF EXISTS vote_decryption_shares;

DROP TABLE IF EXISTS vote_commitments;
DROP TABLE IF EXISTS vote_key_share_participants;


CREATE TABLE [vote_demographic_stats] (
  [statid] INT IDENTITY(1,1) NOT NULL,
  [sum] INT NOT NULL,
  [value] VARCHAR(100) NOT NULL,
  [demographicid] INT NOT NULL,
  [optionid] TINYINT NOT NULL,
  PRIMARY KEY ([statid]),
  CONSTRAINT [FK_vote_demographic_stats.demographicid]
    FOREIGN KEY ([demographicid])
      REFERENCES [vpv_demographic_data]([demographicid]),
  CONSTRAINT [FK_vote_demographic_stats.optionid]
    FOREIGN KEY ([optionid])
      REFERENCES [vote_options]([optionid])
);

CREATE TABLE [vote_commitments] (
  [commitmentid] INT IDENTITY(1,1) NOT NULL,
  [value] INT NOT NULL,
  [sum] INT NOT NULL,
  [optionid] TINYINT NOT NULL,
  PRIMARY KEY ([commitmentid]),
  CONSTRAINT [FK_vote_commitments.optionid]
    FOREIGN KEY ([optionid])
      REFERENCES [vote_options]([optionid])
);