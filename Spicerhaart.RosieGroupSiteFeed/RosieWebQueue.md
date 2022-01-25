# Group Site Feed

The Group site feed is a queue and direct feed from Rosie API to the Elastic database in use by haart and non-haart sites.  

## Queue

The queue is fed by Rosie webhooks and overnight etag sync.

```bash
 COLSQLBI01.Entities.dbo.ListingWebQueue
```

### Webhook processing
Rosie is configured with the master account to send webhooks changes for most entities, including Listings.
The reception point for this is: apollo11.spicerhaart.co.uk/api/RosieWh

This populates COLSQLBI01.[Webhooks].[dbo].[RosieWebhooks] 
This data is processed by  COLSQLBI01.[Webhooks].[dbo].[uspProcessListings] which populates the Entities database AND our queue as above

### Etag Sync

Overnight an etag compoare is performed for every Rosie account by the WHSync package. Any change is fed into the Queue table

## SSIS Package

```python
RosieWebQueue in RexSync in TFS
```

The package uses the queue to request data from the PublishedListings service of the Rosie API. This is because this service contains all fields and overrides relevant for a website feed.
The data is extracted, translated and fed to the elastic upsert API for the website. Currently only haart is enabled.

The package is filtered to only process Colchester haart.

Images are fed direct to the Spicerhaart Azure blobstore https://propimage.blob.core.windows.net/propimage by means of an SAS token which lasts untul 2023 but can be revoked.

## SSIS Package
Roll out
For now the COLSQL10.InternetDB.dbo.RosieMigrationOffice controls which accounts are included in the feed.  