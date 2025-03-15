
CREATE TABLE filer (
  filer_id           SERIAL PRIMARY KEY,
  accession_number   VARCHAR(50) UNIQUE,
  cik                VARCHAR(20),
  filer_name         VARCHAR(255),
  filing_date        DATE,
  amendment_no       VARCHAR(10),
  series_id          VARCHAR(50),
  report_type        VARCHAR(50),
  registrant_type    VARCHAR(100),
  additional_info    TEXT
);

CREATE TABLE issuer (
  issuer_id    SERIAL PRIMARY KEY,
  issuer_name  VARCHAR(255),
  cusip        VARCHAR(20),
  isin         VARCHAR(20),
  figi         VARCHAR(20)
);

CREATE TABLE vote (
  vote_id            SERIAL PRIMARY KEY,
  filer_id           INT NOT NULL REFERENCES filer(filer_id),
  issuer_id          INT NOT NULL REFERENCES issuer(issuer_id),
  meeting_date       DATE,
  matter_voted       TEXT,
  vote_category      VARCHAR(50),
  how_voted          VARCHAR(20),
  for_against_mgmt   VARCHAR(10),
  shares_voted       BIGINT,
  shares_on_loan     BIGINT,
  amendment_flag     BOOLEAN DEFAULT FALSE,
  extra_info         TEXT
);
