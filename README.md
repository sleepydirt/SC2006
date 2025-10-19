# CareerCompass

## System requirements
- Docker

## Development
These are the `compose up` and `compose down` scripts for the development profile:
- `./scripts/dev-up.sh`
- `./scripts/dev-down.sh`

## Production

### Environment variables
- `RAILS_MASTER_KEY`
- `POSTGRES_PASSWORD`

Define these environment variables in `SC2006/.env`.

### Production Server
These are the `compose up` and `compose down` scripts for the production profile:
- `./scripts/prod-up.sh`
- `./scripts/prod-down.sh`
