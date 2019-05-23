# psu-research-metadata

This is the repository for a Ruby on Rails application built for Penn State University Libraries to
gather metadata about Penn State faculty and the research that they conduct and publish. The application
provides a means of semi-automated data importing from several different sources, an administrative
interface for Penn State Libraries admins to manage and curate the data, and an API for end-users and
other applications to access the data. One specific use case for the API is to provide all of the data
needed to produce the kind of profile web page for each faculty member that might be found in the faculty
directory on a department website.

## Data importing and updating

For this application to be relevant and useful, it is important for the data in the production database
to be kept relatively "clean" and current. New data will need to be imported several times per year (likely
after the end of each semester) at a minimum. Our methods for importing new data and updating existing data
are evolving, but we'll attempt to document the process for importing new data here until it is more
completely automated.

Broadly, the process currently consists of three steps for most of the data sources:
1. Gather new data in the form of correctly-formatted files from each source
1. Place the new data files in the conventional location on the production server
1. Run the Rake task to automatically import all of the data from the new files

### Data sources

We import data from a number of other web applications and databases that contain data about Penn State
faculty and research, and we're continuing to add new data sources as we find or gain access to them. Some
of the types of records in our database are currently imported from a single source, and others may be
imported from multiple sources.

Below is a list of the data sources along with the types of records that are imported from each:

1. **Activity Insight** - This is web application/database made by Digital Measures where faculty enter a 
wide variety of data about themselves mainly for the purpose of job/performance review, attaining tenure, 
etc. This application has a REST API to which we have access, but currently we rely on files that are
manually exported by a Penn State Libraries administrator in CSV/spreadsheet format for our data imports.
We import the following types of records from Activity Insight:
    - authorships
    - contracts
    - contributors
    - education_history_items
    - performances
    - performance_screenings
    - presentations
    - presentation_contributions
    - publications
    - users
    - user_contracts
    - user_performances

1. **Pure** - This is a web application/database made by Elsevier.


## API
### Gems
This API is intended to conform to the Swagger 2.0 specification. As such, we're leveraging several gems to simplify the API development workflow, but remain true to the Swagger/Open API standard:
- **swagger-blocks**: a DSL for pure Ruby code blocks that can be turned into JSON (what we're using to generate our API file which will then be used to generate interactive documentation).
- **apivore**: tests a rails API against its OpenAPI (Swagger) description of end-points, models, and query parameters.
- **swagger_ui_engine**: serves up live, interactive API documentation as part of our site. Basically provides a sandbox where users can read about the enpoints and then "try them out". It builds all of this from the API file we build from swagger-blocks.
- **fast_jsonapi**: is what we're using for serialization.

### Suggested API Development Workflow
- Document the new endpoint using the swagger-blocks DSL. Pro tip: Until you get the hang of the DSL, you can use the [interactive swagger editor](https://editor.swagger.io/) for guidance and to check that you have valid Swagger 2.0. Try it out by pasting in the current API file as a starting point: ``` pbcopy < public/api_docs/swagger_docs/v1/swagger.json ``` 
- Once you've got valid Swagger documentation of the new endpoint, you can start TDD'ing beginning with an **apivore** spec. See: ```spec/requests/api/v1/swagger_checker_spec.rb```. The apivore spec will test against the API JSON file, so you'll need to generate a new one each time you update your swagger-blocks DSL documentation. We have a rake task for doing so: ```rake swagger_api_docs:generate_json_file```.
- In addition to the apivore spec, we've also been using request specs to "integration" test our endpoints and params. See: ```spec/requests/api/v1/users_spec.rb``` for an example. The apivore specs are good for ensuring the DSL/documentation jives with the actual enpoints, but the request specs allow us to be more thorough.
- Once specs are passing it's a good idea to manually test the endpoint using the swagger-ui: ```/api_docs/swagger_docs/v1```
