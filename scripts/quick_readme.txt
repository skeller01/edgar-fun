# N-PX Loader

### What this parser does
* Extracts data from EDGAR Form N-PX XML filings and converts it into structured records suitable for database ingestion.
* Accounts for all items defined in the provided schema, including filing headers, manager details, series/class data, and proxy voting records.
* Validates and loads the structured data into an AWS RDS (Postgres) database, ensuring referential integrity and robustness against malformed inputs.

---

## Data-dictionary – Form NPX
# N-PX Filing Parser

This README provides the data dictionary for the SEC N-PX XML parsing project. The table below defines each field extracted from the XML filings according to the current schema.

## Data Dictionary

| Column                     | Data Name                     | Table                   | Data Type           | XPath/XML Tag                  |
|----------------------------|-------------------------------|-------------------------|---------------------|--------------------------------|
| form_id                    | Form ID                       | form_npx                | SERIAL PRIMARY KEY  | N/A                            |
| reporting_person_name      | Reporting Person Name         | form_npx                | VARCHAR(250)        | `.//reportingPerson/name`      |
| phone_number               | Phone Number                  | form_npx                | VARCHAR(50)         | `.//phoneNumber`               |
| address_street1            | Address Street 1              | form_npx                | VARCHAR(250)        | `.//address/street1`           |
| address_street2            | Address Street 2              | form_npx                | VARCHAR(250)        | `.//address/street2`           |
| address_city               | Address City                  | form_npx                | VARCHAR(100)        | `.//address/city`              |
| address_state              | Address State                 | form_npx                | VARCHAR(100)        | `.//address/stateOrCountry`    |
| address_zip                | Address Zip                   | form_npx                | VARCHAR(30)         | `.//address/zipCode`           |
| accession_number           | Accession Number              | form_npx                | VARCHAR(30)         | N/A                            |
| is_parsable                | Is Parsable                   | form_npx                | BOOLEAN             | N/A                            |
| cik                        | CIK                           | form_npx                | VARCHAR(15)         | `.//cik`                       |
| period_of_report_raw       | Period of Report (Raw)        | form_npx                | VARCHAR(50)         | `.//periodOfReport`            |
| conformed_period           | Conformed Period              | form_npx                | DATE                | `.//periodOfReport`            |
| date_filed                 | Date Filed                    | form_npx                | DATE                | N/A                            |
| report_type                | Report Type                   | form_npx                | VARCHAR(100)        | `.//reportType`                |
| form_type                  | Form Type                     | form_npx                | VARCHAR(10)         | `.//submissionType`            |
| sec_file_number            | SEC File Number               | form_npx                | VARCHAR(20)         | `.//fileNumber`                |
| crd_number                 | CRD Number                    | form_npx                | VARCHAR(20)         | `.//reportingCrdNumber`        |
| sec_file_number_other      | SEC File Number Other         | form_npx                | VARCHAR(20)         | `.//reportingSecFileNumber`    |
| lei_number                 | LEI Number                    | form_npx                | VARCHAR(40)         | `.//leiNumber`                 |
| investment_company_type    | Investment Company Type       | form_npx                | VARCHAR(20)         | `.//investmentCompanyType`     |
| confidential_treatment     | Confidential Treatment        | form_npx                | VARCHAR(1)          | `.//confidentialTreatment`     |
| is_notice_report           | Is Notice Report              | form_npx                | BOOLEAN             | `.//reportType`                |
| explanatory_choice         | Explanatory Choice            | form_npx                | VARCHAR(1)          | `.//explanatoryChoice`         |
| other_included_managers_count | Other Included Managers Count | form_npx             | INTEGER             | `.//otherIncludedManagersCount`|
| series_count               | Series Count                  | form_npx                | INTEGER             | N/A                            |
| is_amendment               | Is Amendment                  | form_npx                | BOOLEAN             | `.//isAmendment`               |
| amendment_no               | Amendment No                  | form_npx                | INTEGER             | `.//amendmentNo`               |
| amendment_type             | Amendment Type                | form_npx                | VARCHAR(20)         | `.//amendmentType`             |
| notice_explanation         | Notice Explanation            | form_npx                | VARCHAR(200)        | `.//noticeExplanation`         |
| explanatory_notes          | Explanatory Notes             | form_npx                | VARCHAR(200)        | `.//explanatoryNotes`          |
| signatory_name             | Signatory Name                | form_npx                | VARCHAR(250)        | `.//txSignature`               |
| signatory_name_printed     | Signatory Name Printed        | form_npx                | VARCHAR(250)        | `.//txPrintedSignature`        |
| signatory_title            | Signatory Title               | form_npx                | VARCHAR(100)        | `.//txTitle`                   |
| signatory_date             | Signatory Date                | form_npx                | DATE                | `.//txAsOfDate`                |

| Column                     | Data Name                     | Table                   | Data Type           | XPath/XML Tag                  |
|----------------------------|-------------------------------|-------------------------|---------------------|--------------------------------|
| vote_id                    | Vote ID                       | proxy_voting_record     | SERIAL PRIMARY KEY  | N/A                            |
| issuer_name                | Issuer Name                   | proxy_voting_record     | VARCHAR(250)        | `.//issuerName`                |
| cusip                      | CUSIP                         | proxy_voting_record     | VARCHAR(30)         | `.//cusip`                     |
| isin                       | ISIN                          | proxy_voting_record     | VARCHAR(30)         | `.//isin`                      |
| figi                       | FIGI                          | proxy_voting_record     | VARCHAR(30)         | `.//figi`                      |
| meeting_date               | Meeting Date                  | proxy_voting_record     | DATE                | `.//meetingDate`               |
| vote_description           | Vote Description              | proxy_voting_record     | TEXT                | `.//voteDescription`           |
| proposed_by                | Proposed By                   | proxy_voting_record     | VARCHAR(20)         | `.//voteSource`                |
| shares_voted               | Shares Voted                  | proxy_voting_record     | DECIMAL(14,2)       | `.//sharesVoted`               |
| shares_on_loan             | Shares On Loan                | proxy_voting_record     | DECIMAL(14,2)       | `.//sharesOnLoan`              |
| vote_cast                  | Vote Cast                     | proxy_voting_record     | VARCHAR(50)         | `.//howVoted`                  |
| vote_cast_shares           | Vote Cast Shares              | proxy_voting_record     | DECIMAL(14,2)       | `.//sharesVoted`               |
| management_rec             | Management Recommendation     | proxy_voting_record     | VARCHAR(50)         | `.//managementRecommendation`  |
| other_notes                | Other Notes                   | proxy_voting_record     | TEXT                | N/A                            |

| Column                     | Data Name                     | Table                   | Data Type           | XPath/XML Tag                  |
|----------------------------|-------------------------------|-------------------------|---------------------|--------------------------------|
| category_id                | Category ID                   | matter_category         | SERIAL PRIMARY KEY  | N/A                            |
| category_type              | Category Type                 | matter_category         | VARCHAR(64)         | `.//categoryType`              |

| Column                 | Data Name                | Table                    | Data Type           | XPath/XML Tag                    |
|------------------------|--------------------------|--------------------------|---------------------|----------------------------------|
| manager_id             | Manager ID               | institutional_manager    | SERIAL PRIMARY KEY  | N/A                              |
| form_id                | Form ID                  | institutional_manager    | INTEGER (FK)        | N/A                              |
| serial_no              | Serial Number            | institutional_manager    | INTEGER             | `.//investmentManagers/serialNo` |
| name                   | Manager Name             | institutional_manager    | VARCHAR(250)        | `.//investmentManagers/name`     |
| form13f_number         | Form 13F File Number     | institutional_manager    | VARCHAR(20)         | `.//investmentManagers/form13FFileNumber` |
| crd_number             | CRD Number               | institutional_manager    | VARCHAR(20)         | `.//investmentManagers/crdNumber` |
| sec_file_number        | SEC File Number          | institutional_manager    | VARCHAR(20)         | `.//investmentManagers/secFileNumber` |
| lei_number             | LEI Number               | institutional_manager    | VARCHAR(40)         | `.//investmentManagers/leiNumber` |

| Column                 | Data Name                | Table                    | Data Type           | XPath/XML Tag                    |
|------------------------|--------------------------|--------------------------|---------------------|----------------------------------|
| series_id              | Series ID                | series                   | SERIAL PRIMARY KEY  | N/A                              |
| form_id                | Form ID                  | series                   | INTEGER (FK)        | N/A                              |
| series_code            | Series Code              | series                   | VARCHAR(25)         | `.//seriesReports/idOfSeries`    |
| series_name            | Series Name              | series                   | VARCHAR(250)        | `.//seriesReports/nameOfSeries`  |
| series_lei             | Series LEI               | series                   | VARCHAR(40)         | `.//seriesReports/leiOfSeries`   |

| Column                 | Data Name                | Table                    | Data Type           | XPath/XML Tag                    |
|------------------------|--------------------------|--------------------------|---------------------|----------------------------------|
| series_class_id        | Series Class ID          | series_class             | SERIAL PRIMARY KEY  | N/A                              |
| series_id              | Series ID                | series_class             | INTEGER (FK)        | N/A                              |
| class_id               | Class ID                 | series_class             | VARCHAR(10)         | `.//classInfo/classId`           |
| class_name             | Class Name               | series_class             | VARCHAR(250)        | `.//classInfo/className`         |

| Column                 | Data Name                | Table                    | Data Type           | XPath/XML Tag                    |
|------------------------|--------------------------|--------------------------|---------------------|----------------------------------|
| other_person_id        | Other Person ID          | other_reporting_person   | SERIAL PRIMARY KEY  | N/A                              |
| form_id                | Form ID                  | other_reporting_person   | INTEGER (FK)        | N/A                              |
| ica_form13f            | ICA or Form 13F Number   | other_reporting_person   | VARCHAR(17)         | `.//otherManager/icaOr13FFileNumber` |
| crd_number             | CRD Number               | other_reporting_person   | VARCHAR(20)         | `.//otherManager/crdNumber`      |
| sec_file_number        | SEC File Number          | other_reporting_person   | VARCHAR(17)         | `.//otherManager/otherFileNumber`|
| lei_number             | LEI Number               | other_reporting_person   | VARCHAR(20)         | `.//otherManager/leiNumberOM`    |
| name                   | Manager Name             | other_reporting_person   | VARCHAR(150)        | `.//otherManager/managerName`    |

| Column                 | Data Name                | Table                        | Data Type           | XPath/XML Tag                    |
|------------------------|--------------------------|------------------------------|---------------------|----------------------------------|
| vote_category_id       | Vote Category ID         | proxy_voting_record_category | SERIAL PRIMARY KEY  | N/A                              |
| vote_id                | Vote ID                  | proxy_voting_record_category | INTEGER (FK)        | N/A                              |
| category_id            | Category ID              | proxy_voting_record_category | INTEGER (FK)        | N/A                              |

| Column                 | Data Name                | Table                    | Data Type           | XPath/XML Tag                    |
|------------------------|--------------------------|--------------------------|---------------------|----------------------------------|
| voting_record_manager_id | Voting Record Manager ID | voting_record_manager   | SERIAL PRIMARY KEY  | N/A                              |
| vote_id                | Vote ID                  | voting_record_manager    | INTEGER (FK)        | N/A                              |
| manager_id             | Manager ID               | voting_record_manager    | INTEGER (FK)        | N/A                              |

| Column                 | Data Name                | Table                    | Data Type           | XPath/XML Tag                    |
|------------------------|--------------------------|--------------------------|---------------------|----------------------------------|
| voting_record_series_id | Voting Record Series ID | voting_record_series     | SERIAL PRIMARY KEY  | N/A                              |
| vote_id                | Vote ID                  | voting_record_series     | INTEGER (FK)        | N/A                              |
| series_id              | Series ID                | voting_record_series     | INTEGER (FK)        | N/A                              |





