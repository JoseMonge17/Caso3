
-- Status para comentarios
CREATE TABLE [vpv_proposal_comments_status] (
  [comment_statusid] INT IDENTITY(1,1) NOT NULL,
  [description] VARCHAR(20) NOT NULL,
  CONSTRAINT [PK_vpv_proposal_comments_status] PRIMARY KEY ([comment_statusid])
);

-- Comentarios de proposals
CREATE TABLE [vpv_proposal_comments] (
  [proposal_commentid] INT IDENTITY(1,1) NOT NULL,
  [content] VARCHAR(400) NOT NULL,
  [publish] DATETIME NOT NULL,
  [checksum] VARBINARY(255) NULL,
  [statusid] INT NOT NULL,
  [proposalid] INT NOT NULL,
  [userid] INT NOT NULL,
  CONSTRAINT [PK_vpv_proposal_comments] PRIMARY KEY ([proposal_commentid]),
  CONSTRAINT [FK_vpv_proposal_comments_statusid] FOREIGN KEY ([statusid])
  REFERENCES [vpv_proposal_comments_status]([comment_statusid]),
  CONSTRAINT [FK_vpv_proposal_comments_userid] FOREIGN KEY ([userid])
  REFERENCES [vpv_users]([userid]),
  CONSTRAINT [FK_vpv_proposal_comments_proposalid] FOREIGN KEY ([proposalid])
  REFERENCES [vpv_proposal]([proposalid])
);

-- Documentos asociados a comentarios
CREATE TABLE [vpv_proposal_documents_comments] (
  [documents_commentsid] INT IDENTITY(1,1) NOT NULL,
  [proposal_commentid] INT NOT NULL,
  [documentid] INT NOT NULL,
  [enabled] BIT NOT NULL,
  CONSTRAINT [PK_vpv_proposal_documents_comments] PRIMARY KEY ([documents_commentsid]),
  CONSTRAINT [FK_vpv_proposal_documents_comments_documentid] FOREIGN KEY ([documentid])
  REFERENCES [vpv_digital_documents]([documentid]),
  CONSTRAINT [FK_vpv_proposal_documents_comments_proposal_commentid] FOREIGN KEY ([proposal_commentid])
  REFERENCES [vpv_proposal_comments]([proposal_commentid])
);