# Baseline

Medians from three runs. At each concurrency level every number is the middle value of the three measurements. p50, p95 and p99 are the Total time in milliseconds from the raw `ab` percentage table. A value of 0 ms means `ab` rounded that percentile below 1 ms. Errors are failed requests plus non-2xx responses.

## Environment

- **nginx**: nginx/1.24.0 (Ubuntu), from `nginx -v`
- **ab**: ApacheBench 2.3, revision 1903618, from `ab -V`
- **CPU**: 16 cores, from `nproc`
- **Memory**: 61 Gi, from `free -h`
- **Generator and server**: same machine (`konrad-X870-Pro-RS-WiFi`). `ab` called `http://127.0.0.1/` on port 80, so the load did not cross a network.

## Requests

Each concurrency level sent 2000 HTTP GET requests to `http://127.0.0.1/` (`Document Path: /`). The response was the 615-byte default page. How many requests were in flight at once is the Concurrency column below.

| Concurrency | Median RPS | p50 (ms) | p95 (ms) | p99 (ms) | Errors |
|---|---|---|---|---|---|
| 10 | 43509.47 | 0 | 0 | 0 | 0 |
| 25 | 105602.20 | 0 | 0 | 1 | 0 |
| 50 | 122654.24 | 0 | 1 | 2 | 0 |
| 100 | 115787.65 | 1 | 2 | 4 | 0 |
| 200 | 87542.68 | 1 | 6 | 8 | 0 |
| 400 | 66220.78 | 3 | 15 | 16 | 0 |
