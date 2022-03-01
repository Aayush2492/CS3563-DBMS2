CREATE TABLE ResearchPaper
(
  PaperID INT NOT NULL,
  PaperTitle VARCHAR(100000) NOT NULL,
  PublicationYear INT NOT NULL,
  Venue VARCHAR(100000) NOT NULL,
  Abstract VARCHAR(100000) NOT NULL,
  PRIMARY KEY (PaperID)
);

CREATE TABLE Author
(
  AuthorID INT NOT NULL,
  AuthorName VARCHAR(100000) NOT NULL,
  Similarity_ID INT NOT NULL,
  PRIMARY KEY (AuthorID)
);

CREATE TABLE Authored
(
  PaperID INT NOT NULL,
  AuthorID INT NOT NULL,
  ContributionOrder INT NOT NULL,
  PRIMARY KEY (PaperID, AuthorID),
  FOREIGN KEY (PaperID) REFERENCES ResearchPaper(PaperID),
  FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

CREATE TABLE citation
(
  PaperID_1 INT NOT NULL,
  citationPaperID_2 INT NOT NULL,
  PRIMARY KEY (PaperID_1, citationPaperID_2),
  FOREIGN KEY (PaperID_1) REFERENCES ResearchPaper(PaperID),
  FOREIGN KEY (citationPaperID_2) REFERENCES ResearchPaper(PaperID)
);