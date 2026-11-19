# Tuning journal

Compared at concurrency 400, the highest level in `test_server.sh`. Before values are the medians of the three baseline runs. After values are the single run `wyniki-20261119-175654.csv`. Percentiles come from `surowe-20261119-175654/ab-c400.txt`.

## 1. Raise the connection limit and the file-descriptor limit

**What changed.** `worker_connections` in `/etc/nginx/nginx.conf` went from 768 to 8192. `LimitNOFILE=65535` was added in `/etc/systemd/system/nginx.service.d/override.conf`. The Nginx process soft limit was 1024 and is now 65535.

**Why.** Nginx can accept more simultaneous connections only when both its own `worker_connections` and the systemd file-descriptor limit are raised. The test never opens more than 400 connections at once, which was already below 768.

| Metric | Before (median) | After |
|---|---|---|
| RPS | 66220.78 | 68050.36 |
| p95 (ms) | 15 | 14 |
| p99 (ms) | 16 | 16 |
| Errors | 0 | 0 |

The three baseline runs at this concurrency spanned RPS 63157–69254, p95 14–15 ms, and p99 15–17 ms. Every new number sits inside that span.

**Conclusion.** The change did not improve the result.

## 2. Keepalive to the upstream

**What changed.** Nothing. This step was not applied.

**Why.** Keepalive to an upstream keeps the connection from Nginx to a backend application. This server reads files from `/var/www/html` and has no `proxy_pass` and no process behind it. There is no second connection to reuse. Adding an `upstream` block would still not affect `./test_server.sh http://127.0.0.1/`, because that URL never leaves Nginx. Pointing the test at a proxied path would also require a backend listening on that port, and it would no longer be the same measurement as task 1.

| Metric | Before | After |
|---|---|---|
| RPS | not measured | not measured |
| p95 (ms) | not measured | not measured |
| p99 (ms) | not measured | not measured |
| Errors | not measured | not measured |

**Conclusion.** The change cannot be done on this server without standing up a backend application.

## 3. Cache headers for static files

**What changed.** In `/etc/nginx/sites-available/default`, a location for `jpg`, `jpeg`, `png`, `gif`, `svg`, `webp`, `css`, `js` and `woff2` now sets `expires 30d`, `Cache-Control: public, immutable` and `access_log off`.

**Why.** Browsers can keep those files for 30 days, and Nginx stops writing a log line for them. The measured URL is still `GET /`, which is HTML, so this location does not handle the test requests.

The before column is the previous run, `wyniki-20261119-175654.csv`, at concurrency 400. The after column is `wyniki-20261119-180936.csv` and `surowe-20261119-180936/ab-c400.txt`.

| Metric | Before | After |
|---|---|---|
| RPS | 68050.36 | 64691.42 |
| p95 (ms) | 14 | 15 |
| p99 (ms) | 16 | 16 |
| Errors | 0 | 0 |

The three original runs at this concurrency spanned RPS 63157–69254, p95 14–15 ms and p99 15–17 ms. The new numbers stay inside that span. RPS fell by about 3400, which is less than the 6100 spread of the unchanged runs.

**Conclusion.** The change did not improve the result.

## 4. Gzip for text responses

**What changed.** Under `gzip on` in `/etc/nginx/nginx.conf`: `gzip_comp_level 4`, `gzip_min_length 1024`, and `gzip_types` for plain text, CSS, JSON, JavaScript, XML and SVG.

**Why.** Compressing text responses should cut bytes on the wire. The tested page is 615 bytes, below `gzip_min_length 1024`, so Nginx does not compress it. `ab` also does not send `Accept-Encoding: gzip`.

The before column is `wyniki-20261119-180936.csv` at concurrency 400. The after column is `wyniki-20261119-181504.csv` and `surowe-20261119-181504/ab-c400.txt`.

| Metric | Before | After |
|---|---|---|
| RPS | 64691.42 | 62464.86 |
| p95 (ms) | 15 | 16 |
| p99 (ms) | 16 | 17 |
| Errors | 0 | 0 |

RPS fell by about 2200. The three unchanged runs already differed by about 6100 (63157–69254). p95 and p99 moved by 1 ms, which is the rounding step of the `ab` percentage table.

**Conclusion.** The change did not improve the result.

## 5. Buffer the access log

**What changed.** The main log line in `/etc/nginx/nginx.conf` is now `access_log /var/log/nginx/access.log combined buffer=64k flush=5s`. Nginx keeps log lines in a 64 KB buffer and writes them at least every 5 seconds. `access_log off` for images, CSS and JavaScript stays as it was.

**Why.** Writing every request to disk immediately costs extra I/O. Batching those writes should matter when logging itself is the bottleneck.

The before column is `wyniki-20261119-181504.csv` at concurrency 400. The after column is `wyniki-20261119-183857.csv` and `surowe-20261119-183857/ab-c400.txt`.

| Metric | Before | After |
|---|---|---|
| RPS | 62464.86 | 63538.46 |
| p95 (ms) | 16 | 16 |
| p99 (ms) | 17 | 17 |
| Errors | 0 | 0 |

RPS rose by about 1100. The three unchanged runs already differed by about 6100 (63157–69254). p95 and p99 did not move. The test requests one small HTML page, so the access log was not the limit.

**Conclusion.** The change did not improve the result.
