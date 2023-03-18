# Metadatum 

Metadatum is a free web service that allows Github workflows to post arbitrary
data during an workflow, and query later from the same action, or from future executions.

## Example 
``` 
jobs:
  job1:
    steps:
      - uses: action/checkout@v3
      - uses: launchboxio/save-metadataum-action@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          data: |
            { "message": "Store whatever you want with Metadatum!" }
      - uses: launchboxio/fetch-metadataum-action@v1
        id: metadata
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - run: |
          echo "${{ steps.metadata.outputs.data }} | jq -r '.message'
```

## Features 

- No registration required! Send a Github OIDC token and some data (within limits), and we store it
- Query previously stored metadata by supported fields
- Code is FOSS. Use our free service, or go ahead and deploy your own

## What Metadatum doesn't do

- Because we don't use any external authentication, all requests are authorized to a single repository. Repos are 
are unable to query metadata from another 
- No committment on retention. While we do our absolute best to store provided metadata for up to a week, there's no guarantee.
Its a free service, so storage and bandwidth costs are limited
- We don't store OIDC tokens
- No encryption. Please, don't send API keys, Credit Card numbers, or various forms of PHI / PII to us. While you _can_ encrypt the data in your 
workflows, its not a good idea

We also don't access or store emails, repository or organization names, or keep backups of any data. We 
won't sell your data, simply because we don't have it! We're not interested in usage metrics, upselling
engineers on other services, or designing your web page. If you find a need to store and fetch some metadata during your workflows, we're happy to help

## Why?

More than a few times, I've found the need to store data for Github actions. While you can use workflow artifacts and the like, 
they're a mess to work with. We put together a quick web service, slapped it on some small hardware, and opened it up for usage.
