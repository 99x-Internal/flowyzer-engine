### Metabase

If you run Faros CE locally, you can access the Metabase UI at [http://localhost:3000](http://localhost:3000).

Metabase allows you to create questions (i.e., metrics, charts) from a database and arrange them in dashboards. Your questions and dashboards are stored in collections. They can be shared and embedded.

##### Things to note: Metabase

- Connected to the Flowyzer database.
- Runs abstract queries to get transformed data.
- Serves as the API for the frontend.

##### The Faros CE database

Metabase sits on top of the Faros CE database that receives the data from your systems. Start exploring the data by clicking **Browse Data** in the banner of the Metabase UI.

For each table, you can:

- Look at its content (essentially, drafting a question that grabs everything in that table).
- Look up its schema and associated documentation.
- Do an "X-Ray," i.e., let Metabase automatically build an interesting dashboard about the data in that table.

##### Questions

Questions are your metrics and charts. Questions are made of a query and a visualization.

Queries can be built in the Query Builder UI or through SQL. Get started by clicking **Ask a question** in the banner.

##### Dashboards

Dashboards allow you to present a set of questions.

They can have filters that can be applied to those questions and have interactivity settings, i.e., a way for you to control what happens when a user clicks on a chart. Create a dashboard by clicking the **Create** button in the banner.

Dashboards are saved in a collection.

##### Collections

Collections are hierarchical folders with ACLs where your questions and dashboards are saved. One such collection is the Faros CE collection where all the canned questions and dashboards reside.
