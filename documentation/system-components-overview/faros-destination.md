🚀 Faros Destinations

The Faros Destination is the Airbyte destination connector that takes the data streams extracted by the Airbyte source connectors, and stores it in the Faros CE models. It comes as a pre-packaged and pre-configured destination in your Faros CE instance.

You can find Faros Destination source code [here](https://github.com/faros-ai/airbyte-connectors/tree/main/destinations/airbyte-faros-destination). Of particular interest are the [converters](https://github.com/faros-ai/airbyte-connectors/tree/main/destinations/airbyte-faros-destination/src/converters) that map data from the source streams to our [canonical](https://github.com/faros-ai/faros-community-edition/tree/main/canonical-schema) data model.
