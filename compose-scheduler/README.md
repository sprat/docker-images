# compose-scheduler

A simple cron scheduler for [Docker compose](https://github.com/docker/compose) projects.

## Usage

Here is a `compose.yml` file demonstrating how to use the `compose-scheduler`:
```yaml
services:
  job:
    image: busybox:latest
    command: date
    x-schedule: "* * * * *"
    profiles:  # don't run the container on 'docker compose up'
      - on-schedule

  scheduler:
    image: sprat/compose-scheduler:latest
    volumes:
      - .:/app:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

First, we define the jobs we want to execute periodically. In this example, we defined a service named `job` that will
run the `date` command in a `busybox` image. We added a `x-schedule` element to the service that defines at which time
the job should be executed, which a [cron](https://cron.help/) syntax: in this case, we want to run this job every
minute. We also added a `profiles` element to prevent this job from starting on `docker compose up` since we only
want to run it on a schedule. The profile name by itself has no importance here.

Then, we define a `scheduler` service which will be responsible for running the scheduled jobs, which uses our
`compose-scheduler` image. This scheduler will call `docker compose run <SERVICE>` for each service, each time the
cron expression of the service matches.

Internally, the `compose-scheduler` image contains a `cron` daemon and the `docker compose` CLI. In order to identify
the services that will run periodically, the scheduler need to access the `docker-compose.yml` file of your project and
its context (`.env` files, override files...): that's why the current directory is mounted into the container. The
scheduler also need to access the docker daemon socket to be able to run the jobs containers. The scheduler will
automatically figure out how `docker compose up` was launched and will use the same compose files to run the
jobs.

## TODO

- extend the `x-schedule` syntax to specify `run` parameters?

Some facts & ideas:
- "docker compose run" create a new container for each call => "docker compose" is needed to get the container
parameters for the creation
- we can use "docker compose create" to create (but not execute) the job containers before-hand, then use
"docker start" / "docker compose start" to start them. In this case, we would capture the context.
- we may mount a "sleep_infinity" executable inside the job containers to keep them alive and "exec" their original
commands inside them. However, the stdout/stderr will not appear in the "docker compose up" logs.
- we may implement something like this (and assume that `docker compose` is in the system path):
```bash
compose-with-scheduler <compose options> up <up options>
```

Something that basically work (but the jobs logs don't appear):
```bash
docker compose --profile on-schedule up --build --no-start
docker compose up -d
docker compose --profile on-schedule logs -f
docker compose down --remove-orphans
```
