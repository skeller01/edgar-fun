---------------------------------------------
ADD NEW TABLES 
---------------------------------------
-- 1. Add explanatory_notes to form_npx
ALTER TABLE form_npx
ADD COLUMN explanatory_notes VARCHAR(200);

-- 2. Create series_class table linked to series
CREATE TABLE series_class (
    series_class_id SERIAL PRIMARY KEY,
    series_id INT NOT NULL REFERENCES series(series_id) ON DELETE CASCADE,
    class_id VARCHAR(10),
    class_name VARCHAR(250)
);

CREATE INDEX idx_series_class_series ON series_class(series_id);

-- 3. Add is_parsable boolean to form_npx
ALTER TABLE form_npx
ADD COLUMN is_parsable BOOLEAN DEFAULT TRUE;

-- 4. Create other_reporting_person table
CREATE TABLE other_reporting_person (
    other_reporting_person_id SERIAL PRIMARY KEY,
    form_id INT NOT NULL REFERENCES form_npx(form_id) ON DELETE CASCADE,
    ica_form13f VARCHAR(17),
    crd_number VARCHAR(20),
    sec_file_number VARCHAR(17),
    lei_number VARCHAR(20),
    name VARCHAR(150)
);

CREATE INDEX idx_other_reporting_person_form ON other_reporting_person(form_id);

-----------------------------------------
CLEAR OLD TABLES
------------------------------------------
-- Order matters due to foreign keys
TRUNCATE TABLE
    voting_record_series,
    voting_record_manager,
    proxy_voting_record_category,
    matter_category,
    proxy_voting_record,
    other_reporting_person,
    series_class,
    series,
    institutional_manager,
    form_npx
RESTART IDENTITY CASCADE;


/* ====================================================================== *
   Form N-PX relational schema – **2025-04-24 revision**
   Changes:
   1.  form_npx: added explanatory_notes (VARCHAR 200)
   2.  New child table series_class  (1-to-many off series)
   3.  New table other_reporting_person (cover-page “other persons” list)
 * ====================================================================== */

-- ----------------------------------------------------------------------
--  Master filing header
-- ----------------------------------------------------------------------
CREATE TABLE form_npx (
    form_id                 SERIAL PRIMARY KEY,

    -- Reporting Person / Filer Info
    reporting_person_name   VARCHAR(250) NOT NULL,
    phone_number            VARCHAR(50),
    address_street1         VARCHAR(250),
    address_street2         VARCHAR(250),
    address_city            VARCHAR(100),
    address_state           VARCHAR(100),
    address_zip             VARCHAR(30),

    -- Filing Info
    accession_number        VARCHAR(30),
    is_parsable BOOLEAN DEFAULT TRUE,
    cik                     VARCHAR(15),
    conformed_period        DATE,
    date_filed              DATE,
    report_type             VARCHAR(100),
    form_type               VARCHAR(10),
    sec_file_number         VARCHAR(20),
    crd_number              VARCHAR(20),
    sec_file_number_other   VARCHAR(20),
    lei_number              VARCHAR(40),
    investment_company_type VARCHAR(20),
    confidential_treatment  CHAR(1) CHECK (confidential_treatment IN ('Y','N')) DEFAULT 'N',
    is_notice_report        BOOLEAN DEFAULT FALSE,
    explanatory_choice      CHAR(1) DEFAULT 'N',
    other_included_managers_count INT DEFAULT 0,
    series_count            INT,

    -- Amendment
    is_amendment            BOOLEAN DEFAULT FALSE,
    amendment_no            INT,
    amendment_type          VARCHAR(20),
    notice_explanation      VARCHAR(200),

    -- NEW  ❯❯  Explanatory notes from <explanatoryInformation><explanatoryNotes>
    explanatory_notes       VARCHAR(200),

    -- Signature
    signatory_name          VARCHAR(250),
    signatory_name_printed  VARCHAR(250),
    signatory_title         VARCHAR(100),
    signatory_date          DATE
);

-- ----------------------------------------------------------------------
--  Included institutional managers (summary page)
-- ----------------------------------------------------------------------
CREATE TABLE institutional_manager (
    manager_id       SERIAL PRIMARY KEY,
    form_id          INT NOT NULL REFERENCES form_npx(form_id) ON DELETE CASCADE,
    serial_no        INT,
    name             VARCHAR(250),
    form13f_number   VARCHAR(20),
    crd_number       VARCHAR(20),
    sec_file_number  VARCHAR(20),
    lei_number       VARCHAR(40)
);

-- ----------------------------------------------------------------------
--  Series (fund level)
-- ----------------------------------------------------------------------
CREATE TABLE series (
    series_id   SERIAL PRIMARY KEY,
    form_id     INT NOT NULL REFERENCES form_npx(form_id) ON DELETE CASCADE,
    series_code VARCHAR(25),
    series_name VARCHAR(250),
    series_lei  VARCHAR(40)
);

-- ----------------------------------------------------------------------
--  NEW  ❯❯  Share-class information under each series
-- ----------------------------------------------------------------------
CREATE TABLE series_class (
    series_class_id SERIAL PRIMARY KEY,
    series_id       INT NOT NULL REFERENCES series(series_id) ON DELETE CASCADE,
    class_id        VARCHAR(10),
    class_name      VARCHAR(250)
);

CREATE INDEX idx_series_class_series_id ON series_class(series_id);

-- ----------------------------------------------------------------------
--  Proxy voting records
-- ----------------------------------------------------------------------
CREATE TABLE proxy_voting_record (
    vote_id            SERIAL PRIMARY KEY,
    form_id            INT NOT NULL REFERENCES form_npx(form_id) ON DELETE CASCADE,
    issuer_name        VARCHAR(250),
    cusip              VARCHAR(30),
    isin               VARCHAR(30),
    figi               VARCHAR(30),
    meeting_date       DATE,
    vote_description   TEXT,
    proposed_by        VARCHAR(20),
    shares_voted       NUMERIC(20,6),
    shares_on_loan     NUMERIC(20,6),
    vote_cast          VARCHAR(50),
    vote_cast_shares   NUMERIC(20,6),
    management_rec     VARCHAR(50),
    other_notes        TEXT
);

-- ----------------------------------------------------------------------
--  Matter categories
-- ----------------------------------------------------------------------
CREATE TABLE matter_category (
    category_id    SERIAL PRIMARY KEY,
    category_type  VARCHAR(100) NOT NULL UNIQUE
);

-- Bridge: vote ↔ category
CREATE TABLE proxy_voting_record_category (
    vote_id     INT NOT NULL REFERENCES proxy_voting_record(vote_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES matter_category(category_id) ON DELETE CASCADE,
    PRIMARY KEY (vote_id, category_id)
);

-- Bridge: vote ↔ manager
CREATE TABLE voting_record_manager (
    vote_id    INT NOT NULL REFERENCES proxy_voting_record(vote_id) ON DELETE CASCADE,
    manager_id INT NOT NULL REFERENCES institutional_manager(manager_id) ON DELETE CASCADE,
    PRIMARY KEY (vote_id, manager_id)
);

-- Bridge: vote ↔ series
CREATE TABLE voting_record_series (
    vote_id   INT NOT NULL REFERENCES proxy_voting_record(vote_id) ON DELETE CASCADE,
    series_id INT NOT NULL REFERENCES series(series_id) ON DELETE CASCADE,
    PRIMARY KEY (vote_id, series_id)
);

-- ----------------------------------------------------------------------
--  NEW  ❯❯  “Other persons reporting for this manager” (cover-page list)
-- ----------------------------------------------------------------------
CREATE TABLE other_reporting_person (
    other_person_id      SERIAL PRIMARY KEY,
    form_id              INT NOT NULL REFERENCES form_npx(form_id) ON DELETE CASCADE,
    ica_form13f_number   VARCHAR(17),
    crd_number           VARCHAR(20),
    sec_file_number      VARCHAR(17),
    lei_number           VARCHAR(20),
    manager_name         VARCHAR(150)
);

CREATE INDEX idx_other_person_form ON other_reporting_person(form_id);



-----
SYSTEMS ENG PROMPTS
------
#CODE / PROJECT REVIEW
System / Role Instruction: You are a knowledgeable Data Scientist and Systems Engineer with extensive experience in machine learning, data governance, jupyter notebooks, and software development best practices. You excel at reading code snippets, reviewing project documentation, and producing concise, user-friendly reference materials. User Prompt: I need your help creating a “code review cheat sheet” for a series of surprise meetings where I have to: Justify my project’s existence and impact, Demonstrate code and data handling, Explain core challenges in plain language, Show how the project meets data governance and security requirements. Key Sections for the Cheat Sheet (please include them in the final output in tabular format for easy reference): Purpose & Scope: Provide a high-level overview of the project’s goals—what we’re doing and why it matters. Challenges and Their Solutions (Explained to a 6th Grader): Summarize the main obstacles encountered (including data sources, potential security or logistical hurdles) and how we overcame them, using simple, kid-friendly language. Technical Highlights: Showcase the important code snippets, commits, or specific features that demonstrate achievements. Reference GitHub links or function names where relevant. Performance Metrics & Wins: Provide a short summary of quantifiable improvements (like cost savings, speed gains, or model accuracy improvements) and any relevant stats or charts. Potential Risks or Blockers: Call out known limitations or missing documentation, as well as data governance concerns (e.g., ensuring restricted data isn’t exposed). Next Steps & Action Items: Outline future improvements, tasks to address, or follow-up steps to reassure reviewers that we’re continually refining the project. What I Need From You: Analyze the project materials and incorporate them into the cheat sheet. Use a clear and concise format (like bullet points, tables, or short paragraphs). For potential blockers and risks, evaluate the code or documentation for potential future improvements and corrections. Use a pros-cons-faults-fixes framework but just recommend the fixes in the final table. Highlight any cost savings, time-savings, or other tangible wins that might satisfy the question “Why are you valuable?” Tone & Style: The final cheat sheet should be professional yet straightforward enough to be skimmed quickly by non-technical reviewers. The “challenges” section should be explained like you’re teaching a 6th grader, focusing on clarity and simplicity. For technical sections, assume an audience familiar with coding, but do not reveal sensitive credentials or other restricted data. Please produce the cheat sheet now based on these instructions and the project details I’ve included. Make sure each of the required sections is clearly labeled. My Project Materials Below, I will paste the relevant code snippets, environment details, data diagrams, and any other notes (like the sample code you’ve seen, plus any new details):

#MEMO
Write a memo that summarizes key information in a concise way. The most important topics should go first. Say the main idea, with one supporting thought, maybe 2. Pose outstanding questions if there are any. You can use the format of the four-quadrant update as well, which is accomplishments, challenges (next steps), issues, and metrics (results or metrics to be used).

#Affinity Brainstorming
Background: I'm working on a design project and have gathered various comments, ideas, facts, and observations. I need to organize these into an effective affinity diagram. Follow my directions exactly, do not deviate from my requirements. I only want to see the final summary of the affinity diagram, I do not need to see where every comment was categorized. Task Overview: Initial Clustering: I will provide you with a series of comments or ideas. Your task is to group them into 3-4 categories based on similarities. Grouping into Sub-categories: Once you have the initial categories, I need you to continue clustering the comments in these categories into 3-5 subcategories. This step is about finding themes that make up the initial categories. Creating Subgroups: Within each of the sub-categories, try to create 3-5 subgroups with the comments from the sub-category. This is for more detailed categorization and to ensure a deeper understanding of each top area. Presentation: Present your results in a table format. Do not give me a table with each comment, I only need the categories, subcategories and subgroups. The first column should be the initial categories, then the next column should be the sub-categories and then the subgroups, the last column should show how many comments were in that sub-group and last, I'd like a column that reflects the percentage of the total comments in that subgroup. Here are the comments:

#Quick Systems Engineering and User Story 1-Shot
You are an expert Systems Engineer and Agile Coach. I have an idea/project described as follows: Project Description - 

Your Tasks: Systems Engineering Approach Summarize or restate the requirements and constraints from the information I provided (like an RFP review). Identify or refine High-Level Originating Requirements. Create (or outline) a Context Diagram showing external actors, systems, and data flows. Propose Use Cases and an associated Use Case Behavioral Diagram or short textual descriptions for each key use case. Outline any Concept Fragments or Initial Rough Concept Sketches that would help illustrate the solution. If relevant, include GQM (Goal-Question-Metric) to show how we’ll measure success. Propose or list Performance Metrics and how we’d validate them. If you can, mention how a QFD (House of Quality) or AHP (Analytical Hierarchy Process) might prioritize needs or features. Include a brief timeline (milestones) or a quick “plan to move forward.” Identify Sub-Systems & Allocations (if applicable), as well as Defining Interfaces & Interface Champions. Prepare a short draft of a VCRM (Verification Cross-Reference Matrix) to ensure requirements are testable and verified. Agile Backlog Creation Based on these systems engineering artifacts, create a structured backlog in Scrum/Agile format. Provide Epics (large features or capability areas). Break Epics into User Stories, each with: A clear title (“As a [user], I want [feature], so that [benefit].”) Acceptance Criteria (tie them to performance metrics or requirements from the systems engineering analysis). Story Points or T-Shirt Sizes (if you can). Any references to the relevant Use Cases or QFD priorities. For each User Story, propose possible Subtasks or “child tasks” that outline actual development/test work (e.g., “Implement front-end form,” “Create database schema,” “Write automated tests,” etc.). Where relevant, reference or link to the Systems Engineering artifacts (like the context diagram, use cases, or VCRM). Output Format Present the Systems Engineering summary first (organized by sections: RFP/Requirements Summary, Context Diagram, Use Cases, etc.). Then present the Agile Backlog (Epics, User Stories, Subtasks) in a clear, list-oriented or table-oriented format. Additional Context (optional) {Add any domain-specific standards, compliance issues, or design constraints you want the AI to keep in mind.} Important Goals The final output should be thorough but concise. Each user story must have clear acceptance criteria referencing or derived from the systems engineering process. Show traceability wherever possible. Now, please generate a combined Systems Engineering plan and a groomed Scrum Backlog ready for development based on the information above.

#FFBD
You are an expert process modeler. I want you to create a functional flow diagram (in text form) that resembles a block diagram with labeled functions, AND/OR gates, and references to external inputs/outputs. 1. Read the accompanying project description, documents, articles or whatever is provided and you're going to build a functional flow diagram(s), top level to the bottom level. 2. Your task: - Break down the project into main functions and sub-functions (e.g., Function 2, Function 2.1, 2.2, 2.3...). So, Function 1, Function 2... Function N and then the sub-functions for each, such as Function 1.1, 1.2 etc for each top level function. - Clearly label each function box with a short, meaningful name (e.g., "Function 2: Validate Input"). - Use gates (AND, OR, etc.) to show decision or branching points when breaking out each sub-function. - Show references for external inputs/outputs (e.g., "F.1 Ref" for an incoming request, "F.3 Ref" for final output). - Include any loops or iterative processes with an “IT” or similar notation. - Present it as a text-based flow diagram (ASCII style) that visually indicates the flow from one function to another. 3. Desired format: - Represent each function as a separate diagram - Show each function through its sub-functions as labeled boxes or nodes (and, or, IT nodes). - Represent gates with AND/OR symbols. - Show input references (e.g., F.1 Ref) and output references (e.g., F.3 Ref). - If you can, use indentation or spacing to make the diagram easy to read. - show how functions flow from one thing to another and be conscious of reliability theory, which uses the AND/OR and IT loop gates to determine if total function will fail when estimating probabilities. For example, an AND gate requires both while an OR gate requires one. 4. Include a brief explanation below your diagrams describing each function’s purpose and how the flow works. Please produce the diagrams and explanation now.

#OKR Writing
Transform the following goals into actionable OKRs (Objectives and Key Results) to drive focus and success. Follow these steps: Step 1: Identify Your Objectives. Review your list of objectives or goals. Choose 3-5 high-level objectives that are most important for the upcoming period (e.g., quarter or year). Remember, objectives should be: Qualitative: Describe the desired outcome in a clear and inspiring way. Ambitious: Challenge your team to stretch and achieve significant progress. Actionable: Provide a clear direction for what needs to be accomplished. Step 2: Define Key Results for Each Objective. For each objective, identify 2-5 key results that will measure progress towards achieving it. Key results should be: Quantitative: Use specific metrics and targets to track progress. Measurable: Ensure you can easily track and quantify results at regular intervals. Time-bound: Set a timeframe for achieving each key result (e.g., by the end of the quarter). Leading indicators: Focus on metrics that predict success, not just track past performance. Examples: Objective: Improve customer satisfaction. Key Result 1: Increase Net Promoter Score (NPS) from 60 to 75. Key Result 2: Reduce customer churn rate from 5% to 3%. Key Result 3: Achieve a 90% satisfaction rating on post-support interaction surveys. Objective: Increase brand awareness.  Key Result 1: Grow social media followers by 20%. Key Result 2: Achieve 10,000 monthly website visitors. Key Result 3: Secure 5 media mentions in industry publications.

#Use Case Construction and Systems Context
Do the following: Your task involves two primary objectives: Create a Systems Context Matrix - This is a structured approach to understand your system's environment. Follow these steps: Identify the System Boundary: Clearly define what constitutes the internal elements of your system (like modules and components) and what lies outside (such as users, other systems). List External Entities: Enumerate all the entities that interact with your system, which could include users, other systems, databases, or external services. Define Interactions: Detail the interactions each external entity has with the system. This encompasses the data they exchange, actions taken, and services utilized. Categorize Interactions: Organize these interactions into clear categories for better clarity, such as data inputs and outputs, user actions, system responses, etc. Determine Frequencies and Volumes: Record the frequency of each interaction and, if applicable, the volume of data or number of transactions. This aids in gauging the significance and load of different interactions. Document Assumptions and Constraints: Note any assumptions or constraints that might influence these interactions, including technological limits or regulatory factors. Generate High-Value Use Cases - Based on the matrix, generate 10-20 high-value use cases, considering the following: Identify Functional Requirements: Extract potential use cases from the significant interactions detailed in your matrix. Define Use Cases: For each major interaction, develop a use case describing the actor involved and the system's response. Detail Use Case Scenarios: Elaborate on each use case, outlining the main success scenario, alternate flows, and exception flows. When generating these use cases, ensure to rank them as Low (L), Medium (M), or High (H) in priority. Factor in unintended use cases within a reasonable scope, and give special attention to aspects like safety, security, maintenance, storage, and procedures for startup and shutdown. Build both in table format

#Requirements Quick
Translate the following into mission and functional requirements:

# Requirements Detailed
Write all of the above requirements using the following rules: Write Shall Statements Correct: what you’re saying is accurate Write Shall Statements Clear & Precise: 1 requirement / Idea Write Shall Statements There is no rule 6 Write Shall Statements Unambiguous: only one way interpret Write Shall Statements Objective: non-opinionated Write Shall Statements Verifiable: there is some measurable way you could say this requirement is met Consistent: does not contradict another req. Also provide an abstract name for each individual requirement that helps signify its function in a short way. Make all abstract names unique for that requirement

# Requirements Analysis
As an expert in requirements analysis, follow these precise steps without deviation. Perform the following steps for each requirement and put it into a table with the abstract name, requirement, issue and resolution: Issues: Identify 1-2 major potential issues that could be a technical problem for the requirements or perhaps an issue with the clarity of the requirement. Evidence: Provide a solution for the issues using your deep knowledge of data management and data science. Conclusions: Write a final Resolution to the technical issues identified. Clearly presents the reasoning behind rejected alternatives, highlighting key process milestones.

# Requirements Morphology
From the above requirements, we're going to make a table that finds and narrows potential real-world solutions for each requirement. Do the following without fail: Construct a Morphological Chart: Create a matrix with the identified parameters as the columns. This chart will be used to explore different combinations of components that can fulfill each parameter. Fill the Rows with Components: For each parameter, list potential components or solutions in the rows. These can be derived from existing products or by brainstorming new ideas. Evaluate and Limit Solutions: Use various evaluation strategies to analyze the rows and group parameters. This helps in narrowing down the number of potential principal solutions. Create Principal Solutions: Combine at least one component from each parameter to form complete solutions. This step involves mixing and matching different components to see how they could work together. Analyze and Evaluate Solutions: Assess all the generated solutions against the design criteria or requirements. This helps in selecting a limited number of the most promising principal solutions, usually at least three. Develop Selected Solutions: Further develop the selected principal solutions in detail as part of the ongoing design process.

# Requirements Cost
Create a table that has every requirement and component from the Morphological Chart but also provides an example of an average cost per unit, potential suppliers, estimated quantities and subtotals. Do this for every requirement and at least one realistic component so we have an example for everything.

#Functional Modeling IDEF
Create an IDEF0 for the above system inside a table. Here's how to build the table: For each abstract function name, add a column for each function as a function phrase: verb and noun and add subfunction for each of those functions. Then for each subfunction add ALL Inputs, Outputs, Controls, and Mechanisms (ICOMs) for the entire IDEF0. You can place those all in columns. Remember to check and re-use ICOMs when necessary or appropriate since the outputs of some functions become inputs to others. It's also okay if there are more than one element in each ICOM since a function can have multiple inputs, outputs, controls and mechanisms.

Describe an IDEF0 Based on the above table and make sure functions are connected

Develop an IDEF1X (Integrated Definition for Information Modeling) diagram based on a systems context, both external and internal interactions, and the existing IDEF0 diagram and given requirements or abstract function names. Start by understanding the IDEF0's outlined processes and functions, translating them into data modeling concepts. Focus on identifying key entities, relationships, and attributes. Entities should correlate with the main functions or outputs in the IDEF0 diagram. Define primary keys for each entity and establish relationships between them, indicating cardinality and optionality. Document attributes for each entity, ensuring they align with the data requirements and functions described in the IDEF0 diagram. Employ normalization principles to organize data efficiently and avoid redundancy.

#Goal Question Metric
Using the requirements, idef0 and idef1, create a goal-question-metric analysis (GQM) to help tease out the best metrics to use to track our requirements. Follow these steps in a table. Step 1: Identify Goals of the Measurement. Use the product objectives, functional requirements or sub-system definitions and use the following as good measurement attributes. Clear Singular Target (Analyze … System, Sub-System, or Component Feature) Clear Purpose (For the Purpose of … Functional Req., Sub-System) Relationship to Overall Design Purpose (With Respect to … Product Objective) Clear Perspective (From the Perspective of … User, Buyer, Context Matrix Box) Context is well defined (In the Context of … Environment, Context Matrix Box) Step 2: For each goal generate questions that define the goals in quantitative ways. Step 3: Determine the specific measures that are needed to answer the question. You can make a column for ideal metric and approx metric. Step 4: Determine how we're going to collect the data.

#Subsystem Identification, N2 diagram and Derived Requirements
Organize functions, requirements and components into subsystems, make each subsystem have separate responsibility. Follow these steps: 1. Identify subsystems based on a good understanding of the system functions, requirements and components. 2. Allocate the behavioral and nonbehavioral requirements to the subsystems 3. Identify interconnections between the subsystems (interface specifications) 4. assign inputs and outputs between the subsystems based on the interconnections 5. identify incidental interactions Put this into a table where each column is a subsystem and the rows are requirements

Build an N2 diagram for the subsystems

Based on this N2 diagram how would you derive more requirements that would be emergent? Determine derived requirements and trace them back to the originating requirements, now that you know how the subsystems interact. Put the derived requirements into a table with the abstract name, requirement, issue and from which requirement it is derived: Identify 1-2 major potential issues that could be a technical problem for the requirements or perhaps an issue with the clarity of the requirement. Evidence: Provide a solution for the issues using your deep knowledge of data management and data science. Conclusions: Write a final Resolution to the technical issues identified. Clearly presents the reasoning behind rejected alternatives, highlighting key process milestones. Make sure all these requirements are new and come from interacting components and subsystems.

#State
Based on the requirements, derived requirements, subsystems and N2 diagram, build a state diagram as a table which shows the states this system could possibly be in. A state shows a different mode of operation, a specific set of parameter values, different external conditions or different sets of rules or performance metrics that are applied

#Testing
For every requirement, both functional and derived, write a test plan in table format. The columns should be TestID, Test method, test facilities, entry condition and exit condition

#Risk - FMEA
Now build a functional modes and effect analysis for each subsystem based on the functions of each subsystem. we're going to identify functional failure. Do the following in a table: Select items or functions for analysis; Identify failure modes for each item; Assess the potential impact of each failure mode; Brainstorm possible causes for each failure mode; Suggest corrective actions for each possible cause; Rate the severity of the potential impact; Rate the likelihood of occurrence of each possible cause; Assess the risk; Prioritize the corrective actions.

for the highest risks, build a fault tree risk probability and pump out new derived requirements to mitigate the risk. also provide the appropriate tests