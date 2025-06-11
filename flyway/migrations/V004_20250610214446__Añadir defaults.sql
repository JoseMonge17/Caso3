ALTER TABLE vote_elegibility
ADD CONSTRAINT DF_vote_elegibility_registeredDate
DEFAULT GETDATE() FOR registeredDate;

ALTER TABLE vote_ballots
ADD CONSTRAINT DF_vote_ballots_voteDate
DEFAULT GETDATE() FOR voteDate; 