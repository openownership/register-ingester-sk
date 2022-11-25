# Register Ingester SK

Register Ingester SK is an application designed for use with beneficial ownership data from Register published by Slovakia.

## One-time Setup

Ingest indexes:
```
bin/run setup_indexes
```

## Ingesting Snapshots

### 1. Ingest

```
bin/run ingest
```

If the SK_STREAM key is set, new records will also be published to the AWS Kinesis Stream.

## Testing

First build the docker image with:
```
bin/build
```
Then tests can be executed by running:
```
bin/test
```

## Configuration

```
BODS_AWS_REGION=
BODS_AWS_ACCESS_KEY_ID=
BODS_AWS_SECRET_ACCESS_KEY=

ELASTICSEARCH_HOST=
ELASTICSEARCH_PORT=443
ELASTICSEARCH_PROTOCOL=https
ELASTICSEARCH_SSL_VERIFY=true
ELASTICSEARCH_PASSWORD=

SK_STREAM=
```

- Elasticsearch credentials - these must be set
- SK_STREAM - If this is set, newly discovered records (ie ones not previously ingested) will be published to the AWS Kinesis stream with this name
