# Register Ingester SK

Register Ingester SK is a data ingester for the [OpenOwnership](https://www.openownership.org/en/) [Register](https://github.com/openownership/register) project. It processes bulk data published in the Public Sector Partners Register collected by the Ministry of Justice in Slovakia, and ingests records into [Elasticsearch](https://www.elastic.co/elasticsearch/). Optionally, it can also publish new records to [AWS Kinesis](https://aws.amazon.com/kinesis/). It uses raw records only, and doesn't do any conversion into the [Beneficial Ownership Data Standard (BODS)](https://www.openownership.org/en/topics/beneficial-ownership-data-standard/) format.

## Installation

Install and boot [Register](https://github.com/openownership/register).

Configure your environment using the example file:

```sh
cp .env.example .env
```

- `SK_STREAM`: AWS Kinesis stream to which to publish new records (optional)

Create the Elasticsearch indexes:

```sh
docker compose run ingester-sk create-indexes
```

## Testing

Run the tests:

```sh
docker compose run ingester-sk test
```

## Usage

To ingest the bulk data:

```sh
docker compose run ingester-sk ingest-bulk
```
