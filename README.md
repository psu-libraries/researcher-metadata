![Penn State Libraries Logo](https://metadata.libraries.psu.edu/psu_libraries.png)

# Researcher Metadata Database (RMD)

This is the repository for a Ruby on Rails application built for Penn State University Libraries to
gather metadata about Penn State faculty and the research that they conduct and publish. The application
provides a means of semi-automated data importing from several different sources, an administrative
interface for Penn State Libraries admins to manage and curate the data, and an API for end-users and
other applications to access the data. One specific use case for the API is to provide all of the data
needed to produce the kind of profile web page for each faculty member that might be found in the faculty
directory on a department website. The application also provides an interface for faculty users to see
an example of what a profile page about them would look like, and a management interface for them to
adjust some preferences with regard to how data appears in their profile. This interface includes features
that allow ORCiD users to automatically send metadata from RMD to populate their ORCiD records. It also
includes features that support Penn State's open access policy/initiative by allowing faculty users to
submit metadata about the open access status of each of their publications.

## Data Importing and Updating

For this application to be relevant and useful, it is important for the data in the production database
to be kept relatively "clean" and current. For some of the external data sources, the process of extracting
data from the source and importing it into RMD has been fully automated, and the process is performed on a
regular basis. For other sources, the process involves several manual steps, and we try to update data from
these sources at least a couple of times per year.

The process for data that must be imported manually generally consists of three steps:
1. Gather new data in the form of correctly-formatted file(s) from the source
1. Place the new data file(s) in the conventional location on the production server
1. Run the Rake task to automatically import all of the data from the new file(s)

### Data Sources

We import data from a number of other web applications and databases that contain data about Penn State
faculty and research, and we're continuing to add new data sources as we find or gain access to them. Some
of the types of records in our database are currently imported from a single source, and others may be
imported from multiple sources.

Below is a list of the data sources along with the types of records that are imported from each:

1. **Activity Insight** - This is web application/database made by Digital Measures where faculty enter a 
wide variety of data about themselves mainly for the purpose of job/performance review, attaining tenure, 
etc. We use this application's [REST API](https://webservices.digitalmeasures.com/login/service/v4) (API key
required) for directly importing data. A cron job automatically runs this import in production once per day.
We import the following types of records from Activity Insight:
    - authorships
    - contributor_names
    - education_history_items
    - performances
    - performance_screenings
    - presentations
    - presentation_contributions
    - publications
    - users
    - user_performances

1. **Pure** - This is a web application/database made by Elsevier. It contains data about Penn State
researchers, their published research, and the organizations within Penn State to which they belong.
This data mostly has to do with scientific research that is published in peer-reviewed journals, so
we don't get much data about faculty in the arts and humanities from this source as opposed to Activity
Insight which provides data about faculty across the whole university. This application also has a
well-documented [REST API](https://pennstate.pure.elsevier.com/ws/api/511/api-docs/index.html) (API key
required) to which we have access. We use this API for directly importing data, but the import is not
yet scheduled to run automatically. We import the following types of records from Pure:
    - authorships
    - contributor_names
    - journals
    - organizations
    - publications
    - publication_taggings
    - publishers
    - tags
    - user_organization_memberships
    - users

1. **eTD** - This is a web application/database developed by the Penn State Libraries that facilitates
the submission and archival of PhD dissertations and Masters theses in digital format by graduate students.
Our main reason for importing metadata from this source is to be able to show the graduate student advising
that each faculty member has done. Because the application currently has no API, we don't have a way to
automate the importing of data. Currently, we obtain an SQL dump of the eTD database, load this dump into a
local MySQL database and export several .csv files which we then import into our database. We import the
following types of records from eTD:
    - committee_memberships
    - etds
    
1. **Penn State News RSS feeds** - The Penn State News website publishes many
[RSS feeds](https://news.psu.edu/rss-feeds), and we import news story metadata directly from several of
them whenever a story involves a specific Penn State Faculty member. A cron job automatically runs this
import in production once per hour. We import the following types of records
from news.psu.edu:
    - news_feed_items

1. **Penn State LDAP** - We import some data for existing user records from Penn State's directory of people.
A cron job runs this import in production once per hour.

1. **Web of Science** - We performed a one-time import of a static set of publication and grant data from
Web of Science for publications that were published from 2013 to 2018. We obtained a copy of this data on
a physical disk. We import the following types of records from Web of Science:
    - authorships
    - contributor_names
    - grants
    - publications
    - research_funds

1. **National Science Foundation** - We import grant data that we download from the National Science
Foundation [website](https://nsf.gov/awardsearch/download.jsp) in the form of XML files. We import the
following types of records from NSF:
    - grants
    - researcher_funds

1. **Open Access Button** - We import URLs to the content of open access publications that are provided by
Open Access Button via their web [API](https://openaccessbutton.org/api). We only look up publications in
Open Access Button by DOI, so this import only adds data to existing publications in our database that have
DOIs. This import is not yet scheduled to run automatically.

1. **Penn State Law School repositories** - We import publication metadata from the repositories maintained
by the Penn State Law School at University Park and the Dickinson School of Law at Carlisle via the Open 
Archives Initiative Protocol for Metadata Harvesting (OAI-PMH). Dickinson maintains the 
[IDEAS repository](https://ideas.dickinsonlaw.psu.edu/), and Penn State Law maintains the
[Penn State Law eLibrary](https://elibrary.law.psu.edu/). Part of our reason for importing metadata from
these sources is to facilitate onboarding the law school faculty into Activity Insight. In the future, we
may not need to import data from these sources since new data may eventually be available via Activity Insight.
This import not currently scheduled to run automatically. We import the following types of records from these
repositories:
    - authorships
    - contributor_names
    - publications

### Obtaining New Data
While much of our data importing is fully automated, some of it involves parsing files that are manually 
exported/downloaded from a data source. By convention, we place those files in the `db/data/` directory
within the application and give them the names that are  defined in `lib/tasks/imports.rake`. This directory
in the repository is ignored by revision control, and on the application servers it is shared between
application releases. The data sources that involve a manual export/import process are described below.

#### eTD
The process for obtaining and preparing eTD data for import involves several steps.
1. Obtain an SQL dump of the production database for the graduate school instance of the eTD app.
1. Create a MySQL database locally and load in the eTD production dump.
1. The production database dump contains a view called `student_submissions` that presents most of the eTD data
that we need to import, but it's missing one column that we need. So, in our local database we need to add
one additional column called `submission_public_id` to the `student_submissions` view:

    ```sql
    CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `metadata_import_view`
    AS SELECT
       `s`.`id` AS `submission_id`,
       `s`.`semester` AS `submission_semester`,
       `s`.`year` AS `submission_year`,
       `s`.`created_at` AS `submission_created_at`,
       `s`.`status` AS `submission_status`,
       `s`.`access_level` AS `submission_acccess_level`,
       `s`.`title` AS `submission_title`,
       `s`.`abstract` AS `submission_abstract`,
       `s`.`public_id` AS `submission_public_id`,
       `authors`.`access_id` AS `access_id`,
       `authors`.`first_name` AS `first_name`,
       `authors`.`middle_name` AS `middle_name`,
       `authors`.`last_name` AS `last_name`,
       `authors`.`alternate_email_address` AS `alternate_email_address`,
       `authors`.`psu_email_address` AS `psu_email_address`,
       `p`.`name` AS `program_name`,
       `d`.`name` AS `degree_name`,
       `d`.`description` AS `degree_description`,
       `id`.`id_number` AS `inv_disclosure_num`,group_concat(concat(`cm`.`name`,_utf8'|',nullif(`cm`.`email`,_utf8'|'),_utf8' ',`cr`.`name`) order by `cr`.`id` ASC separator ' || ') AS `committee_members`
    FROM ((((((`submissions` `s` left join `invention_disclosures` `id` on((`s`.`id` = `id`.`submission_id`))) left join `authors` on((`s`.`author_id` = `authors`.`id`))) left join `programs` `p` on((`s`.`program_id` = `p`.`id`))) left join `degrees` `d` on((`s`.`degree_id` = `d`.`id`))) left join `committee_members` `cm` on((`s`.`id` = `cm`.`submission_id`))) left join `committee_roles` `cr` on((`cm`.`committee_role_id` = `cr`.`id`))) group by `s`.`id`;
    ```
NOTE: The default SQL mode in MySQL 5.7 and later enables several modes including `ONLY_FULL_GROUP_BY` that were turned off by default in older versions. `ONLY_FULL_GROUP_BY` causes the `student_submissions` view to be rejected. Here's some background on this issue:

https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sql-mode-changes
https://www.percona.com/blog/2019/05/13/solve-query-failures-regarding-only_full_group_by-sql-mode/

To restore operation for the `student_submissions` view we've been turning off SQL modes when starting a new MySQL
session like so: `mysql.server start --sql-mode=''` To verify no modes were activated go into MySQL and do the following:
``` mysql> SELECT @@sql_mode; ```
Note: This approach is somewhat heavy-handed, but the results from the `student_submissions` view seem okay. A more precise approach would be to not invoke `ONLY_FULL_GROUP_BY` when starting a new MySQL session and leave all
the other modes activated.
    
1. After starting up MySQL with SQL modes turned off, dump the new view of the eTD data to a tab-separated file with `echo 'SELECT submission_id, submission_semester, submission_year, submission_status, submission_acccess_level, submission_title, access_id, first_name, middle_name, last_name, degree_name, submission_public_id FROM metadata_import_view' | mysql -B -u root etdgradrailprod > etds.tsv`,
substituting your local database name if you called it something different.
1. Open the TSV file in vim. You'll probably see that the file is littered with `^M` control characters that we
need to remove. Enter the command `:%s/^M//g` to remove all of them (NOTE: you'll need to literally type ctrl-vm in 
that vim command, not carrot-M). Write the file.
1. Open the TSV file in Excel or Numbers and export it as a UTF-8 encoded CSV file. Save it in the data import
directory in this project (`db/data/`) as `etds.csv`.
1. Dump the committee data with `echo 'SELECT submission_id, email, committee_role_id FROM committee_members' | mysql -B -u root etdgradrailprod > etd_committees.tsv`
again substituting the name of your local database if necessary.
1. Again, open `committees.tsv` in Excel or Numbers and export as a UTF-8 encoded CSV file, `db/data/committees.csv`.

#### National Science Foundation
In the `lib/utilities/` directory in this repository, there is a utility script for automatically downloading grant
data from the National Science Foundation website and preparing it for import by decompressing the files and placing
them in the correct location.

### Importing New Data
Once updated data files have been obtained (if applicable) and the necessary API keys have been installed,
importing new data is just a matter of running the appropriate rake task. These tasks are all defined in
`lib/tasks/imports.rake`. An individual task is defined for importing each type of data from each source. We also
define a single task that imports all types of data from all sources, `rake import:all`. In practice there's no
need to run this task in production since much of the importing is scheduled to run automatically. This task serves
mostly to help you import data in development, and to give you an idea of the order in which the individual imports
should be generally be run so as to get the most complete set of data in one pass. All of these tasks are designed
to be idempotent given the same source data and database state. For the data sources that require manual export/import,
the individual import tasks will occassionally need to be run in production. While it's sometimes necessary to import
data directly from the sources in development for QA/testing, it's much faster to establish a useful development
database by loading a dump of the production data.

### Identifying Duplicate Publication Data
Because we import metadata about research publications from more than one source, and because duplicate entries
sometime exist even within the same data source, we need a means of finding multiple records in our database that
represent the same publication after we have finished importing data. This helps to ensure that users don't receive
duplicate data when they query our own API. There is logic built into the processes that import publication metadata
that will search for possible duplicate publications that already exist and group them as each new publication
record is imported. This allows admin users to later review the groups and pick which record in each group to keep
while dicarding the rest. Subsequent imports of the same data will then not recreate the discarded duplicates. There's
also a rake task, `rake group_duplicate_pubs`, which uses the same duplicate finding/grouping logic. Running this task
will check every publication record in the database for possible duplicates and group them.

### Merging Duplicate Publication Records
Whenever we import a new publication, we create a record in two different tables in the database. We create a record
for the publication itself which contains the publication's metadata, and we create a record of the import which
contains information about the source of the import (the name of the source, and the unique identifier for the
publication within that source). The record of the import has a foreign key to the record of the publication.

Then, whenever we run a publication import, for each publication in the input data, the first thing that we do is
look for an import record that has the same source name and unique identifier. If one exists, then we know that we
already imported the publication from this source, and we may or may not update the existing publication record
depending on whether or not the record has been updated by an administrator. If no import record exists, we create
new records as described above.

When we discover two publication records that are duplicates, each of those will have its own import record as well.
For example, Publication Record 1 has an associated import record with the import_source being "Activity Insight"
and the source_identifier being "123". Publication Record 2 is a duplicate of publication record 1, and it has an
associated import record with the import_source being "Pure" and the source_identifier being "789". Whenever an admin
user merges these two publication records, the following happens:
1. The admin user picks one publication record to keep (probably the one with the most complete/accurate metadata).
1. We take the import record from the publication record that we're not keeping and reassign it to the publication record that we are keeping.
1. We delete the publication record that we're not keeping.
1. We flag the publication record that we kept as having been manually modified by an admin user because we assume that the admin has picked the record with the best data (and possibly also made corrections to the chosen data after the merge), and we don't want future imports to overwrite this manually curated data.

So in the example, if we merge the duplicate publications and decide to keep Publication Record 2, then it will now
have both import records - the one from Pure and the one from Activity Insight, and Publication Record 1 will be
deleted. Then when we reimport publications from Pure and we come to this publication in the data, we'll find the
import record for Pure attached to Publication Record 2, and we won't create a new record (but may update the existing
record). Likewise when we reimport publications from Activity Insight.

Occasionally publication records that are not actually duplicates appear similar enough that they are mistakenly 
grouped as potential duplicates by our duplicate identification process. In this situation, it's possible for admin
users to select and group publications as a way of indicating that they have been reviewed and have been determined
to not be duplicates even though they look similar. This will prevent the same publications from automatically being
grouped as potential duplicates again in the future.

### Import Logic
In general, data imports create a new record if no matching record already exists. If a matching record does already
exist, then the import may update the attributes of that record. However, for records that can be fully or partially
updated by admin users of this app, we keep track of whether or not a record has been modified in any way by an admin.
If a record has been modified by an admin user, then subsequent data imports no longer update that record because we assume
that any changes that were made manually by an admin user are corrections or additions that we don't want to overwrite.
Data imports never delete whole records from our database - even if formerly present records have been removed from the
data source.

Importing `user` records involves some additional logic since we import user data from two sources (Pure and Activity
Insight). We take Activity Insight to be the authority on user data when it is present, so an import of a user's data
from Activity Insight will overwrite existing data for that user that has already been imported from Pure, but not 
vice versa.

What constitues a "match" for the sake of finding and updating existing records depends on the type of record. For
example, we uniquely identify users by their Penn State WebAccess ID. For most other records, we record their unique
ID within the data source.

### Journal Article vs. Non-Article Publications
All publication types are imported during the publication import from Activity Insight and Pure.  Conference proceedings, 
books, editorials, abstracts, and many others are being imported as publications along with journal articles.  A journal article 
is defined as any publication that contains the string "Journal Article" in its publication_type.  Non-article publications 
(which are sometimes referred to as "Other Works" in the UI and other_publications in the code) are defined as any publication 
that does not have the string "Journal Article" in its publication_type.  Journal articles and non-article publications are 
displayed in separate interfaces of the user profile interface, public profile interface, and profile API endpoint.  All 
publications are displayed together in the publication API endpoint.  Non-article publications are not included in the 
open access workflow.  However, they can be exported to ORCiD if they have a url.  All publications behave the same in the Admin 
interface.

## API
### Gems
The RMD API is intended to conform to the Swagger 2.0 specification. As such, we're leveraging several gems to simplify the API development workflow, but remain true to the Swagger/Open API standard:
- **swagger-blocks**: a DSL for pure Ruby code blocks that can be turned into JSON (what we're using to generate our API file which will then be used to generate interactive documentation).
- **apivore**: tests a rails API against its OpenAPI (Swagger) description of end-points, models, and query parameters.
- **swagger_ui_engine**: serves up live, interactive API documentation as part of our site. Basically provides a sandbox where users can read about the enpoints and then "try them out". It builds all of this from the API file we build from swagger-blocks.
- **fast_jsonapi**: is what we're using for serialization.

### Suggested API Development Workflow
- Document the new endpoint using the swagger-blocks DSL. Pro tip: Until you get the hang of the DSL, you can use the [interactive swagger editor](https://editor.swagger.io/) for guidance and to check that you have valid Swagger 2.0. Try it out by pasting in the current API file as a starting point: ``` pbcopy < public/api_docs/swagger_docs/v1/swagger.json ``` 
- Once you've got valid Swagger documentation of the new endpoint, you can start TDD'ing beginning with an **apivore** spec. See: ```spec/requests/api/v1/swagger_checker_spec.rb```. The apivore spec will test against the API JSON file, so you'll need to generate a new one each time you update your swagger-blocks DSL documentation. We have a rake task for doing so: ```rake swagger_api_docs:generate_json_file```.
- In addition to the apivore spec, we've also been using request specs to "integration" test our endpoints and params. See: ```spec/requests/api/v1/users_spec.rb``` for an example. The apivore specs are good for ensuring the DSL/documentation jives with the actual enpoints, but the request specs allow us to be more thorough.
- Once specs are passing it's a good idea to manually test the endpoint using the swagger-ui: ```/api_docs/swagger_docs/v1```

## ORCID Integration
### Background
Since much of the data that is stored in the Researcher Metadata database is the same data that
people would use to populate their ORCID records, it's useful for us to offer users the ability to
automatically write their data to ORCID. In order to do this, our application must be authorized to
update the ORCID record on behalf of the user.

Penn State has a system that allows users to connect their ORCID records to their Penn State Access
Accounts. This system uses the usual 3-legged OAuth process to obtain the user's ORCID iD and a
read/write access token from ORCID. The access token so obtained has permission to read data from the
user's ORCID record and also to write data to their record via ORCID's API. This access token and ORCID
iD are stored in a database managed by Penn State central IT. The ORCID iD is then published in the 
user's Penn State LDAP record.

### Researcher Metadata Database Integration
#### Current Workflow
In our production environment, a job runs houly that queries Penn State LDAP for each user in our database
and saves their ORCID iD if it is present in their LDAP record. We then use the presence of the ORCID iD 
that we obtained in this way to determine if the user can connect their Researcher Metadata profile to
their ORCID record. If we've obtained an ORCID iD from LDAP, then they are able to make this new
connection.

If such a user chooses to connect their Researcher Metadata profile to their ORCID record, then they
go through the 3-legged OAuth process again, and we receive our own read/write access token for the user's
ORCID record. We save the data that we obtained directly from ORCID in this way (including the access
token and the user's ORCID iD) to the user's record in our database and use it for all subsequent ORCID
API calls on behalf of that user. It should be noted that if a user has multiple ORCID accounts, then
the ORCID iD that they've connected to their Penn State Access Account could be different from the ORCID
iD that they've connected to their Researcher Metadata profile.

#### Ideal Workflow
Currently, it's not possible for us to access the ORCID OAuth access tokens that are stored in the database
at Penn State central IT. If it were, then we could simply use those tokens instead of obtaining our own.
This would simplify our process and eliminate the possibility that different ORCID iDs for a given user
could end up being linked to the two different systems. This would also make the workflow much more streamlined
for our users and prevent Penn State from needing to pay for an additional ORCID integration. However, it
will probably add a little complexity in terms of caching access tokens and attempting to retrieve a new
token if we find the one in our cache to no longer be valid.

The best compromise for now is to only allow users who have linked their ORCID records to their Penn State 
Access Accounts to also link them to their Researcher Metadata profile. This ensures that if we are later
able to use the centralized access tokens, then one of those tokens will exist for every user who has linked
their ORCID record to their Researcher Metadata profile. It also gives users one more incentive to link their
ORCID record to their Penn State Access Account (which we want them to do regardless).

## RMD and Open Access
Penn State has adopted a [policy](https://openaccess.psu.edu/) requiring most research published by faculty
at the University to be made freely available to the public. Part of the purpose of RMD is to support this
policy by encouraging faculty members to comply and by helping to provide them with the means and guidance
to do so. RMD is capable of determining (based on its own data) which faculty members have authored publications
that are subject to the policy and that may not be in compliance, and it's capable of sending a notification by
email to each of these faculty members with a list of the publications that may require action. This list of
publications links back to the user interface in RMD that faculty use to manage their profile preferences. This
interface shows a list of all of the user's publications and the open access status of each. For each publication
that has an unknown open access status, there are several actions that a user may take in order to comply with the
policy including:
1. providing a URL to an open access version of their work that has already been published on the web
1. visiting [ScholarSphere](https://scholarsphere.psu.edu/) and depositing an open access version of their work
1. submitting a waiver if an open access version of their work cannot be published for some reason

Before notifying users in this way, we attempt to obtain as much open access status information as possible so
that we're not bothering people about publications that are already open access. To do this, we use the DOIs that
we have imported from various sources to query Open Access Button and attempt to obtain a URL for an existing
open access version of the work. Currently the processes for obtaining as much data as possible beforehand and
for sending the email notifications are triggered manually by rake tasks in the production environment. The
task for importing data from Open Access Button is `rake import:open_access_button`, and the task for sending
the notifications is `rake email_notifications:send_all_open_access_reminders`. As the name of the latter task
indicates, it sends an email to *every* user who meets the criteria for receiving one. It may be more desireable
to actually send the emails in smaller batches in some cases, which is supported by the code underlying the
rake task. There is also a task for sending a test email containing mock data to a specific email address for the
purposes of testing/demonstration:  `rake email_notifications:test_open_access_reminder[email@example.com]`.

For each user, we record the time when they were last sent an open access reminder email, and for each publication
we also record this time in the user's authorship record so that we know which publications we've already
reminded the user about. The logic for determining who, out of a given set of users, should receive an email
includes a check of this timestamp so that we never email the same person more often than once every six months
regardless of how often we run the emailing task.

If a user takes any of the possible actions to comply with the open access policy for a publication, then the
result will be recorded in RMD, the open access status of the publication will change, and the user will no
longer be notified about the publication.

## Dependencies
This application requires PostgreSQL for a data store, and it has been tested with PostgreSQL 9.5 and 10.10. Some functionality requires the [pg_trgm module](https://www.postgresql.org/docs/9.6/pgtrgm.html) to be enabled by running `CREATE EXTENSION pg_trgm;` as the PostgreSQL superuser for the application's database.

---

This project was developed by the The Pennsylvania State University Libraries Digital Scholarship and Repository Development team in collaboration with [West Arete](https://westarete.com).
