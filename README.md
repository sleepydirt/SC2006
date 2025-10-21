# CareerCompass

## System requirements
- Docker
> [!NOTE]  
> Please ensure that Docker Desktop is downloaded and WSL integration is turned on (for Windows).

## Setup

### Development
You do not need to configure any environment variables for development. 

**Start the development server:**

> [!IMPORTANT]  
> These scripts only work on a bash terminal. For Windows machines, please use the docker compose commands instead.

```bash
$ ./scripts/dev-up.sh
```

Alternatively,

```bash
$ docker compose -f compose.dev.yaml up -d --build
```

**To stop the server:**

```bash
$ ./scripts/dev-down.sh
```

Alternatively,

```bash
$ docker compose -f compose.dev.yaml down
```

Ensure that the server is running in development mode:
```bash
$ docker exec sc2006-app-1 bin/rails r "puts Rails.env"
```

The app can be accessed at `http://localhost:3000`.
### Production
Create a `.env` file in the root directory (`SC2006/.env`)
```bash
$ cp .env.example .env
```

Delete existing master key and credentials located at `app/config/master.key` and `app/config/credentials.yml.enc`

Generate a new pair of credentials:
```bash
$ bin/rails credentials:edit
```

then define the environment variables:
- `RAILS_MASTER_KEY`
- `POSTGRES_PASSWORD`

**Start the production server:**

```bash
$ ./scripts/prod-up.sh
```
Alternatively,
```bash
$ docker compose up -d --build
```

**To stop the server:**

```bash
$ ./scripts/prod-down.sh
```
Alternatively,
```bash
$ docker compose down -v
```

Access the app at http://localhost:3000

## Testing

To run all unit tests:
> [!CAUTION]  
> You need to run the command INSIDE the docker container during development, running `rails test` outside the container will fail.
```bash
$ docker exec sc2006-app-1 bin/rails test
```
