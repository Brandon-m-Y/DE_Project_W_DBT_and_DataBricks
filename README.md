# Job Postings Analytics with dbt and Databricks

A data engineering project that transforms raw job postings data stored in Databricks into analytics-ready tables using dbt.

> **Status:** In active development. The raw data is loaded and the dbt project is set up. Transformation models are being built next.

## Tech stack

| Layer | Tool |
| --- | --- |
| Data platform | Databricks (Unity Catalog) |
| Transformation | dbt |
| Language | SQL, Python 3.13 |
| Environment and dependencies | [uv](https://docs.astral.sh/uv/) |

## Data

Raw job postings land in the Databricks table `raw.jobs.raw_job_postings`. Each row is one posting, tagged with the `search_term` used to collect it.

Example: count postings per search term ([raw.session.sql](raw.session.sql)):

```sql
SELECT
    search_term,
    COUNT(*) AS postings
FROM raw.jobs.raw_job_postings
GROUP BY search_term
ORDER BY postings DESC;
```

## Project structure

```
.
├── analytics/            # dbt project
│   ├── dbt_project.yml   # dbt config (uses the "databricks" profile)
│   ├── models/           # SQL transformation models
│   ├── macros/           # reusable Jinja/SQL macros
│   ├── seeds/            # static CSV reference data
│   ├── snapshots/        # slowly changing dimension snapshots
│   └── tests/            # custom data tests
├── src/                  # Python package
├── raw.session.sql       # exploratory queries against the raw layer
├── pyproject.toml        # project metadata and dependencies
└── uv.lock               # locked dependency versions
```

## Getting started

### 1. Install dependencies

```bash
uv sync
```

### 2. Configure the Databricks connection

dbt reads connection details from `~/.dbt/profiles.yml`, which lives outside this repository so credentials are never committed. Add a profile named `databricks`:

```yaml
databricks:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: dev
      schema: default
      host: <your-workspace>.cloud.databricks.com
      http_path: /sql/1.0/warehouses/<warehouse-id>
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      threads: 4
    prod:
      type: databricks
      catalog: prod
      schema: default
      host: <your-workspace>.cloud.databricks.com
      http_path: /sql/1.0/warehouses/<warehouse-id>
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      threads: 4
```

Then set your access token as an environment variable:

```bash
export DATABRICKS_TOKEN=<your-personal-access-token>
```

### 3. Run dbt

```bash
cd analytics
uv run dbt debug     # check the connection
uv run dbt build     # run models and tests against the dev target
```

To deploy to production, add `--target prod`.

## Environments

| Target | Catalog | Purpose |
| --- | --- | --- |
| `dev` | `dev` | Development and testing |
| `prod` | `prod` | Production tables |
