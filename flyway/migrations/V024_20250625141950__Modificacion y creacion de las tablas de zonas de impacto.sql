CREATE TABLE [dbo].[vpv_zone_type] (
    [zone_typeid] INT IDENTITY(1,1) PRIMARY KEY,
    [name] VARCHAR(100) NOT NULL
);

CREATE TABLE [dbo].[vpv_impact_zone] (
    [zoneid] INT IDENTITY(1,1) PRIMARY KEY,
    [name] VARCHAR(100) NOT NULL,
    [zone_typeid] INT NOT NULL,
    FOREIGN KEY (zone_typeid) REFERENCES [dbo].[vpv_zone_type](zone_typeid)
);

CREATE TABLE [dbo].[vpv_impact_level] (
    [impact_levelid] INT IDENTITY(1,1) PRIMARY KEY,
    [name] VARCHAR(50) NOT NULL
);

CREATE TABLE [dbo].[vpv_proposal_impact_zones] (
    [proposal_impactid] INT IDENTITY(1,1) PRIMARY KEY,
    [proposalid] INT NOT NULL,
    [zoneid] INT NOT NULL,
    [impact_levelid] INT NOT NULL,
    [description] VARCHAR(255) NULL,
    FOREIGN KEY (proposalid) REFERENCES [dbo].[vpv_proposal](proposalid),
    FOREIGN KEY (zoneid) REFERENCES [dbo].[vpv_impact_zone](zoneid),
    FOREIGN KEY (impact_levelid) REFERENCES [dbo].[vpv_impact_level](impact_levelid)
);