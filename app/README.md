# Remix Weather Application

Displays current weather conditions (via the [OpenWeather API](https://openweathermap.org)) for Algonquin College, Woodroffe Campus. Originally from the Week 3 lab ([`rlmckenney/cst8918-w25-a01-weather`](https://github.com/rlmckenney/cst8918-w25-a01-weather)), copied in here and wired up to read its cache from Redis in test/prod.

## Environment variables

See [`.env.example`](.env.example).

- `WEATHER_API_KEY` (required) - a free key from [OpenWeather](https://home.openweathermap.org/users/sign_up).
- `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` / `REDIS_TLS` (optional) - when `REDIS_HOST` is unset, `app/api-services/open-weather-service.ts` falls back to an in-memory cache, so local dev doesn't need Redis running. In test/prod these are set on the Kubernetes deployment from `infra/modules/weather-app` (issue #5), pointing at Azure Cache for Redis (TLS on port 6380 by default).

## Local development

```sh
cp .env.example .env   # then fill in WEATHER_API_KEY
npm install
npm run dev
```

## Docker

```sh
docker build -t weather-app .
docker run -p 8080:8080 --env-file .env weather-app
```
