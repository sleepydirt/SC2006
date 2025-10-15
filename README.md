# CareerCompass

## System requirements
- Docker

## Setup
### Environment variables
- `RAILS_MASTER_KEY`
- `POSTGRES_PASSWORD`

Define these environment variables in `SC2006/.env`.

### Development/Production Server
```
$ docker compose up -d --build
```

The app should then be running on `http://localhost:3000`.
