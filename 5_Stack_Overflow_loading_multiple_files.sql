-- Location To load dataframes:

SHOW VARIABLES LIKE "secure_file_priv";

-- Load Badges XML


CREATE TABLE badges(
  Id INT,
  UserId INT,
  Name VARCHAR(500),
  Date DATETIME, 
  Class INT,
  TagBased VARCHAR(10)
);


LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_OverflowBadges.xml"
INTO TABLE badges
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM badges;

DROP TABLE badges;



-- Load Comments

CREATE TABLE Comments(
  Id INT,
  PostId INT,
  Score INT,
  Text varchar(1000) 
  );
  
LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_Overflow/Comments.xml"
INTO TABLE Comments
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM Comments;

DROP TABLE Comments;

-- Load Table PostHistory

CREATE TABLE PostHistory(
  Id INT,
  PostHistoryTypeId INT,
  PostId INT,
  RevisionGUID TEXT, -- Change to TEXT or LONGTEXT if necessary
  CreationDate DATETIME,
  UserId INT,
  Text LONGTEXT -- This should already be able to store large text data
);

LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_Overflow/PostHistory.xml"
INTO TABLE PostHistory
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM PostHistory;

DROP TABLE PostHistory;

-- Load Table PostLinks

CREATE TABLE PostLinks(
  Id INT,
  CreationDate DATETIME,
  PostId INT,
  RelatedPostId INT,
  LinkTypeId INT
);

LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_Overflow/PostLinks.xml"
INTO TABLE PostLinks
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM PostLinks;

-- Load Table Posts

CREATE TABLE Posts(
  Id INT,
  PostTypeId INT,
  CreationDate DATETIME,
  Score INT,
  ViewCount INT,
  Body TEXT,
  OwnerUserId INT,
  LastActivityDate DATETIME,
  Title TEXT,
  Tags TEXT,
  AnswerCount INT,
  CommentCount INT,
  ContentLicense TEXT
);

LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_Overflow/Posts.xml"
INTO TABLE Posts
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM Posts;

-- Load Table Tags

CREATE TABLE Tags(
  Id INT,
  TagName TEXT,
  Count INT,
  ExcerptPostId INT,
  WikiPostId INT
);

LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_Overflow/Tags.xml"
INTO TABLE Tags
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM Tags;

-- Load Table Users

CREATE TABLE Users(
  Id INT,
  Reputation INT,
  CreationDate DATETIME,
  DisplayName TEXT,
  LastAccessDate DATETIME,
  WebsiteUrl TEXT,
  Location TEXT,
  AboutMe TEXT,
  Views INT,
  UpVotes INT,
  DownVotes INT,
  AccountId INT
);

LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_Overflow/Users.xml"
INTO TABLE Users
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM Users;

DROP TABLE Users;

-- Load Table Votes

CREATE TABLE Votes(
  Id INT,
  PostId INT,
  VoteTypeId INT, 
  CreationDate DATETIME
);

LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stack_Overflow/Votes.xml"
INTO TABLE Votes
ROWS IDENTIFIED BY '<row>';

SELECT * 
FROM Votes;



