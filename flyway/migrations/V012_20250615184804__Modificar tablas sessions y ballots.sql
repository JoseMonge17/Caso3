ALTER TABLE vote_sessions
DROP COLUMN threshold;

ALTER TABLE vote_sessions
DROP COLUMN key_shares;

ALTER TABLE vote_ballots
ALTER COLUMN proof VARBINARY(255) NULL;
