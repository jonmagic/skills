# Closure Review Fixtures

These synthetic fixtures exercise review scope and implicit-contract discovery.
They are intentionally small, but the review prompt should not reveal the
material finding.

## Fixture A: large-batch incident fix

PR intent: prevent an incident-sized metrics batch from exceeding the runtime's
function-argument limit.

```ts
// src/metrics/create.ts
export async function createMetrics(client: Client) {
  const rows: MetricRow[] = []
  await processResults(client, async (batch) => {
    appendAll(rows, batch)
  })

  enrichRows(rows)
  return rows
}

export function appendAll<T>(target: T[], source: T[]) {
  for (const item of source) {
    target.push(item)
  }
}
```

```ts
// src/metrics/enrich.ts
export function enrichRows(rows: MetricRow[]) {
  const enrichedRows = rows.map(enrichRow)
  rows.splice(0, rows.length, ...enrichedRows)
}
```

```ts
// src/metrics/create.test.ts
it('appends one million rows without throwing', () => {
  const rows: number[] = []
  appendAll(rows, Array.from({ length: 1_000_000 }, (_, index) => index))
  expect(rows).toHaveLength(1_000_000)
})
```

## Fixture B: structural composition and telemetry

PR intent: add selective cache behavior to `GlobalScanConsumer`, protected by a
disabled rollout flag.

```ruby
# app/lib/cacheable.rb
module Cacheable
  def self.included(base)
    base.prepend(RuntimeRules)
    base.prepend(BatchLifecycle)
  end

  module RuntimeRules
    def runtime_rules
      cached? ? reduced_rules : super
    end
  end

  module BatchLifecycle
    def complete_batch
      result = super
      commit_cache
      result
    end
  end
end
```

```ruby
# app/consumers/global_scan_consumer.rb
class GlobalScanConsumer < Consumers::RuleRunningConsumer
  include Cacheable
end
```

```ruby
# app/lib/consumers/base_consumer.rb
class Consumers::BaseConsumer
  def self.consumer_type
    ancestors.second.to_s.delete_prefix("Consumers::")
  end
end
```

```ruby
# app/lib/consumers/rule_running_consumer.rb
stats.timing(
  "consumer.latency",
  elapsed,
  tags: ["consumer_type:#{self.class.consumer_type.downcase}"],
)
```

```text
# ops/global-scan-dashboard.txt
avg:consumer.latency{consumer_type:rulerunningconsumer}
```

## Fixture C: decorator identity and persistence

PR intent: extract retry logging into a reusable decorator without changing
handler output.

```python
# handlers/retry.py
def logged_retry(fn):
    def wrapper(*args, **kwargs):
        logger.info("retrying", extra={"handler": fn.__name__})
        return fn(*args, **kwargs)
    return wrapper
```

```python
# handlers/payments.py
@logged_retry
def capture_payment(command):
    return gateway.capture(command)
```

```python
# persistence/commands.py
def serialize(command):
    return {
        "handler_type": command.handler.__name__,
        "payload": command.payload,
    }
```

Persisted records and replay routing use `handler_type == "capture_payment"`.

## Fixture D: additive shadow with a dormant live-action flag

PR intent:

- Add a shadow worker beside the legacy poller.
- Enable `shadow_worker_enabled` during validation.
- Keep `shadow_live_actions_enabled` off until a later cutover decision.
- Compare both paths before changing production ownership.

The tests deliberately assert that the shadow starts a replacement scan when
live actions are enabled, while the legacy path remains present.

```ruby
# app/consumers/publish_package_consumer.rb
LegacyPoll.enqueue(job)
ShadowPoll.enqueue(job) if Flipper.enabled?(:shadow_worker_enabled)
```

```ruby
# app/consumers/shadow_poll_worker.rb
def retry_failed_scan(job)
  stats.increment("shadow.retry_failed_scan")
  return unless Flipper.enabled?(:shadow_live_actions_enabled)

  status_url = Scanner.start_scan(job.restart_payload)
  ShadowPoll.enqueue(job.restart(status_url))
end
```

```ruby
# test/consumers/shadow_poll_worker_test.rb
it "starts a replacement scan when live actions are enabled" do
  Flipper.enable(:shadow_live_actions_enabled)
  Scanner.expects(:start_scan).once

  worker.retry_failed_scan(failed_job)
end
```

The rollout notes say to validate the no-op shadow first and settle production
ownership before enabling live actions. They do not say whether duplicate
replacement scans during a temporary dual-live phase are intended.
