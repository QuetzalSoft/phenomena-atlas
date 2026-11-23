# 0016 - The index recomputation is triggered by EventBridge Scheduler and Lambda

- Status: accepted
- Date: 2026-11-22

## Context

Something must wake up to run the computations that are due (ADR 0015). Hosting is not
decided yet; this assumes AWS, and cost must be minimal. The team referred to Hangfire as
the model.

**`@nestjs/schedule` in the API process**: no new infrastructure, but it needs an
always-on process. App Runner throttles the CPU when there are no requests, and Lambda is
not always on.

**pg-boss**: a queue backed by Postgres, the closest to Hangfire, with retries and a
dashboard. It creates its own schema outside the Kysely migrations. It is the fallback if
those features are needed.

**BullMQ**: needs Redis, which the project does not have.

**One EventBridge schedule per phenomenon**: every schedule must be kept in sync from the
API through the AWS SDK.

**ECS RunTask per tick**: slower to start and more expensive.

**pg_cron**: cannot run the TypeScript translation of the weighting function.

## Decision

**One tick per minute: one invocation that runs the computations that are due.**
EventBridge Scheduler, with `rate(1 minute)`, the flexible time window off and no retries,
invokes a Lambda function:

- arm64, 512 MB, a 5-minute timeout;
- reserved concurrency 1;
- asynchronous invocation with a maximum event age of 60 seconds and 0 retries;
- in the VPC, connecting to RDS with IAM authentication.

**Each tick asks Postgres which phenomena are due** and computes them, stopping before the
Lambda's time runs out. The rest stay due for the next tick.

**The tick is a plain function with two entry points and no NestJS bootstrap**, like
`migrate` and `set-role`: the Lambda handler, and a local script, `bun run
index:recompute-due` (`--every 60` to repeat). Everything but the AWS wiring is developed
and tested locally.

**The infrastructure is described here and created with the hosting work**, not by #44.

**A missed tick loses nothing.** Each tick asks Postgres what is due, so a tick that fails
or is discarded leaves its work due for the next one. That is why neither the schedule nor
the Lambda retries.

## Consequences

Good:

- About $0 a month while ticks stay short: about 44,640 invocations, within the free tiers
  of EventBridge Scheduler and Lambda.
- Nothing has to be kept in sync with AWS when an admin saves, publishes, archives or
  deletes a phenomenon.

Bad, and accepted deliberately:

- If the hosting is not AWS, this record must be superseded.
- There is no dashboard or run history as Hangfire has, only logs.
- One-minute resolution.
- `nodejs26.x` must be generally available on Lambda before production, or a container
  image is used.
- A database that pauses when idle, such as Aurora Serverless with auto-pause, would never
  pause.
- The cost traps to avoid are a NAT gateway, Secrets Manager through a VPC endpoint, and
  RDS Proxy.
- The AWS wiring can only be verified once the AWS environment exists.
