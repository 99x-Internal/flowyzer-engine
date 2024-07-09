### Hasura

You can access the Hasura UI at [http://localhost:8080](http://localhost:8080).

Hasura provides a `GraphQL layer` on top of your database, automatically leveraging the key relationships between your tables. It provides facilities for interacting with the canonical models in Faros CE, including GraphQL Explorer, data explorer for the Postgres database, injecting custom logic, API stitching, and eventing.

##### Things to note: Hasura

- Hasura is the API gateway that lets us read and write to the database that we have.
- Airbyte pumps all the source data to Postgres through Hasura.
- The GraphQL endpoints are used to write to the database.
- The `Hasura GraphQL Engine` automatically generates a GraphQL schema based on the tables and views in your database. You no longer need to write a GraphQL schema, endpoints, or resolvers.

#### GraphQL endpoint

The GraphQL endpoint is typically `/v1/graphql`; you can find its location in the Hasura UI. This is the endpoint used by the `Faros Destination connector`.

It is possible to create REST endpoints from your GraphQL queries. Read more in the Hasura UI: [Hasura Console](http://localhost:8081/console/api/rest/list).
