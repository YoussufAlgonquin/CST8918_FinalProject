import Redis from 'ioredis'

const API_KEY = process.env.WEATHER_API_KEY
const CACHE_TTL_SECONDS = 60 * 10 // 10 minutes

// In prod/test this points at the Azure Cache for Redis instance from
// infra/modules/weather-app (REDIS_HOST/REDIS_PORT/REDIS_PASSWORD set on
// the k8s deployment). Falls back to an in-memory cache for local dev
// when REDIS_HOST isn't set.
const redis = process.env.REDIS_HOST
  ? new Redis({
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT ? Number(process.env.REDIS_PORT) : 6380,
      password: process.env.REDIS_PASSWORD,
      // Azure Cache for Redis requires TLS on its default port (6380).
      tls: process.env.REDIS_TLS === 'false' ? undefined : {},
    })
  : null

// ioredis crashes the process on an unhandled 'error' event (e.g. the pod
// starts before Redis is reachable) - just log it instead. Individual
// get/set calls below will still reject while disconnected; ioredis
// queues and retries them once the connection recovers.
redis?.on('error', (err) => {
  console.error('Redis connection error:', err)
})

const memoryCache: Record<string, { lastFetch: number; data: unknown }> = {}

async function getCacheEntry(key: string): Promise<unknown> {
  if (redis) {
    const cached = await redis.get(key)
    return cached ? JSON.parse(cached) : undefined
  }
  const entry = memoryCache[key]
  if (entry && Date.now() - entry.lastFetch < CACHE_TTL_SECONDS * 1000) {
    return entry.data
  }
  return undefined
}

async function setCacheEntry(key: string, data: unknown): Promise<void> {
  if (redis) {
    await redis.set(key, JSON.stringify(data), 'EX', CACHE_TTL_SECONDS)
    return
  }
  memoryCache[key] = { lastFetch: Date.now(), data }
}

interface FetchWeatherDataParams {
  lat: number
  lon: number
  units: string
}
export async function fetchWeatherData({
  lat,
  lon,
  units,
}: FetchWeatherDataParams) {
  const baseURL = 'https://api.openweathermap.org/data/2.5/weather'
  const queryString = `lat=${lat}&lon=${lon}&units=${units}&appid=${API_KEY}`

  const cached = await getCacheEntry(queryString)
  if (cached !== undefined) {
    return cached
  }
  const response = await fetch(`${baseURL}?${queryString}`)
  const data = await response.json()
  await setCacheEntry(queryString, data)
  return data
}

export async function getGeoCoordsForPostalCode(
  postalCode: string,
  countryCode: string,
) {
  const url = `http://api.openweathermap.org/geo/1.0/zip?zip=${postalCode},${countryCode}&appid=${API_KEY}`
  const response = await fetch(url)
  const data = response.json()
  return data
}
