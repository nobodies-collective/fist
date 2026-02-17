# Codex Would Do Better

This document is intentionally opinionated.

It infers the product's true goals from behavior and domain context, compares those goals to current implementation reality, and proposes a better rebuild direction.

## Inferred Product Goals

1. Get enough volunteers into the right roles at the right times.
2. Keep onboarding friction low, especially for ticket holders.
3. Let leads/metaleads run staffing autonomously without manager bottlenecks.
4. Support real-time coordination during event and strike.
5. Preserve continuity year-over-year with low migration risk.
6. Maintain trust: permissions, privacy, auditability, and stable operations.

## Gap Analysis: Goal vs Reality

## 1) Goal: Clear, trustworthy permissions

Current reality gaps:

- NoInfo pages are guarded by `isALead` on routes, not strict NoInfo role.
- Client guard and server method guards do not always communicate the same intent.
- Some privileged access (for example contact lookup) is audit-logged only to console output.

Why this is a problem:

- Role boundaries are hard to reason about.
- Operational trust degrades when policy and behavior diverge.

## 2) Goal: Low-friction operations for managers

Current reality gaps:

- User-management UI lacks active ban/unban and password-reset controls, while server support partially exists.
- JSON rota import/export methods exist but are not wired into active manager screens.
- Annual migration requires a developer to pre-change hardcoded event scope.

Why this is a problem:

- Managers cannot fully operate the system independently.
- "Self-service" admin workflows become pseudo-manual workflows.

## 3) Goal: Fast staffing decisions, especially under pressure

Current reality gaps:

- Urgency scoring and signup logic are split between app code and package code, increasing mental overhead.
- Search/filter UX does not fully match expected staffing workflows (skill/quirk/priority filtering not in current lead search UI).
- Critical state flags (`enrolled`, `reviewed`, `notification`) are subtle and easy to mis-handle.

Why this is a problem:

- Staffing velocity depends on operator understanding of hidden rules.
- Debugging wrong notifications or assignment states is harder than it should be.

## 4) Goal: Predictable annual rollover

Current reality gaps:

- Event scope is hardcoded (`Volunteers.eventName`) and migration flow depends on code edits.
- Import operations are destructive and backup strategy is weak/implicit.
- Historical role carry-forward also appears in migration scripts, fragmenting rollover logic.

Why this is a problem:

- Rollover is one of the highest-risk operations and currently has avoidable sharp edges.

## 5) Goal: Maintainable engineering surface

Current reality gaps:

- Mixed UI stacks (React + Blaze/AutoForm bridges) increase coupling and reduce clarity.
- Core behavior lives across app code and package internals; contracts are implicit.
- Significant behavior depends on method naming conventions rather than typed contracts.
- Test surface is limited relative to operational criticality.

Why this is a problem:

- Small changes have high regression risk.
- Rebuild or migration work is harder than necessary.

## 6) Goal: Privacy and compliance confidence

Current reality gaps:

- Sensitive volunteer form fields (including medical/emergency data) are widely accessible to lead-facing flows.
- Contact access audit is not durable enough (console logs are insufficient as an audit ledger).
- Data-retention/deletion workflows are not first-class product features.

Why this is a problem:

- Elevated legal and trust risk.
- Hard to demonstrate least-privilege and compliance posture.

## Where The System Feels Over-Complicated

1. Event rollover depends on both runtime settings and hardcoded scope constants.
2. Role checks exist in multiple layers with inconsistent specificity.
3. Notification state is modeled as per-signup booleans instead of explicit event logs.
4. UI capability and method capability are mismatched (methods exist but no screen path).
5. Date/time handling includes many edge-case compensations (`+1 day`, period hacks) instead of a single normalized model.

## What A Better Rebuild Should Optimize For

## Product principles

1. Manager can operate the system end-to-end without developer intervention.
2. Permission behavior is explicit, testable, and identical across UI/API.
3. Staffing workflows are optimized for "time-to-fill" critical duties.
4. Migration/rollover is safe-by-default, reversible, and observable.
5. Privacy-sensitive data follows strict least-privilege controls.

## Architecture principles

1. Single typed API contract (no hidden method coupling).
2. Single source of truth for role decisions (policy engine/RBAC layer).
3. Explicit job orchestration with idempotent workers.
4. Event scope is runtime data, never hardcoded in app source.
5. First-class audit/events table for privileged actions.

## Codex Proposed "Better" Scope (Not 1:1 Parity)

## A) Fix contradictions first

1. Enforce strict NoInfo route and method permissions consistently.
2. Align manager UI with existing capabilities (or remove dead capabilities).
3. Make annual rollover fully UI/API driven with no code change pre-step.

## B) Simplify domain model behavior

1. Keep `signups` but add immutable signup event log (`created`, `reviewed`, `enrolled`, `bailed`, `notified`).
2. Replace implicit notification booleans with explicit notification events + dedupe key.
3. Make early-entry derivation a tested query/service, not scattered logic.

## C) Improve operator UX

1. Add real staffing filters (skill, quirk, priority, availability windows).
2. Add a "what changed" activity feed for leads/metaleads/managers.
3. Add migration dry-run and diff preview before apply.

## D) Improve safety and compliance

1. Durable audit trail table for contact access and sensitive profile views.
2. Field-level access policy for medical/emergency data.
3. Built-in retention/deletion workflows and reports.

## E) Reduce engineering drag

1. Remove Blaze bridge and standardize on one UI stack.
2. Collapse package/app behavioral split into explicit modules or services.
3. Add contract tests for all privileged endpoints and cron jobs.

## Suggested Rebuild Sequence

1. Model and policy layer first (schemas, roles, permissions matrix).
2. Signup/workflow engine with deterministic tests.
3. Staffing dashboards + search UX.
4. Notifications and job runner.
5. Migration/rollover tooling with dry-run support.
6. Privacy/audit/reporting hardening.

## Success Criteria For "Better" (Not Just "Same")

1. Zero developer-required steps for annual rollover.
2. Every privileged action has durable audit records.
3. Permission matrix can be generated and validated automatically.
4. Time-to-fill urgent shifts improves measurably during live operations.
5. Managers can complete all documented admin workflows from UI.
6. Rebuild has comprehensive workflow-level tests for high-risk paths.

## Bottom Line

The current system already captures valuable domain logic and real operational lessons. A better rebuild should preserve that logic while removing accidental complexity, role contradictions, and operational bottlenecks.

Rebuilding "exactly as written" would preserve avoidable pain. Rebuilding "for clarity and operations" should be the target.
