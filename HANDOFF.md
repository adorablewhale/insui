# insui handoff - 2026-10-06

- j5cks-1.4.6 published at 1480449; anonymous public bytes match the release commit.
- normal cloud sync 60 seconds; watched sync remains 5 seconds. quiet deferral stays
  capped at 45 seconds (normal maximum gap 105 seconds plus network time).
- tests/test_cloud_cadence.lua is an isolated Matcha scheduler regression, no network
  or consent writes. new code passes, old code fails. compile and 193 locals pass.
- candidate copied to C:/matcha/workspace/INSUI/insui.lua and loaded by FischHub
  2.6.3 in the live game. online (60-second sync), auto fish off.
- website migration 0013 and INSUI-only version notice deployed, Worker
  bcc3056f-577b-438e-a39b-3051e2722c69. FischHub public version stays 2.6.2.
  direct D1 metadata confirms one heartbeat write instead of two; live sessions recovered.
- context: website hit D1's 100k daily write limit; direct API returned 7500 and
  normal live reporting resumed at 00:00 UTC (7 pm Chicago, Oct 6). see the kit's
  HANDOFF_V2.md. graph is stale; refresh only on owner approval.
