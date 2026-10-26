# ADR 0001: Feature-first layers with shared task ownership

- Status: Accepted for the architecture starter
- Date: 2026-10-26
- Scope: Flutter structure and dependency boundaries

## Context

Tarteeb has Campus and Personal experiences that share tasks. The repository began
with requirements documentation, with Firebase configuration and full dashboards
scheduled separately. A fresh checkout must run without a private Firebase project.
The structure must keep modes independent while allowing one task implementation.

## Decision

Organize by feature under `lib/features`, with `presentation`, `application`,
`domain`, and `data` layers added as needed. Use `features/shared/tasks` for the
single task model, repository contract, Riverpod state, and list UI. Mode-specific
screens compose it. `app` owns navigation and infrastructure wiring. `core` holds
only technical foundations with no dependency on features.

Keep domain types pure Dart. Application providers depend on domain repository
interfaces; data adapters implement those interfaces. Select adapters via Riverpod
overrides at the composition root. Start with an in-memory adapter and fictional
fixtures; later inject a Firebase adapter without changing the shared UI.

Use built-in Riverpod providers without generation for the initial slice. Keep
ephemeral navigation state local; use Riverpod for asynchronous feature state.
Do not add an abstraction or use-case class unless it contains meaningful logic.

## Alternatives considered

1. Top-level `screens/`, `models/`, `services/`: simple initially, but a feature's
   changes spread across unrelated folders and shared ownership becomes unclear.
2. Separate task implementations per mode: easy local iteration, but duplicates
   validation, persistence and error behavior. Rejected.
3. Firebase calls directly in widgets/providers: fast prototype, but makes startup
   configuration mandatory and couples UI tests to infrastructure. Rejected.
4. Fully generated clean-architecture scaffolding: adds build tooling and many
   pass-through classes before complex domain behavior exists. Defer generation
   and extra abstractions until their benefit is demonstrated.

## Consequences

- Both modes evolve independently while sharing task behavior and tests.
- Domain and widget tests run without credentials or Firebase emulators.
- App bootstrap is the deliberate exception allowed to import concrete adapters.
- Provider overrides must be installed at startup; tests cover the real entry point.
- More boundaries require discipline; an import test and documented conventions
  provide early feedback.
- The starter is read-only demo data, not a complete task product. Firebase,
  authentication, editing and offline persistence remain follow-up work.

## Validation

See [architecture](../architecture.md) for the diagram and dependency table,
and [verification](../verification.md) for actual automated and UI results.
