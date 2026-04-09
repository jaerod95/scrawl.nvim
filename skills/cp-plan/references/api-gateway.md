# api-gateway

Node.js 18, ESM, Sequelize ORM, Express. Manages the Applause platform's APIs.

## File Organization

- One function per file, all named `index.js`, each in its own directory
- Import aliases: `#models`, `#procedures`, `#services`, `#helpers`, `#configs`, `#job-queues`
- Never import from relative parent directories — always use `#`-prefixed paths or sub-directories

## Pipe Pattern

Core abstraction for data transformation flows:

```javascript
pipe({ amount: 100, locationId: 5 })
  .bind("async")
  .flow(getLocation)
  .flow(getBudgetConfig)
  .flow(validateAmount)
  .flow(calculateTotals)
  .runAsync()
```

Each step takes a context object and returns a new context object.

## Procedure Structure

Business logic lives in `procedures/` organized by domain:

```
procedures/{domain}/{operation}/
├── index.js          # pipe definition
├── queries/          # data fetching, adds to context
├── actions/          # transformations, calculations
└── validators/       # constraint checks, throw on failure
```

## Code Style

- Avoid async/await except in tests and migrations
- Inline functions only used once
- Alphabetical sorting when order doesn't matter (arrays, imports, object keys)
- Single-line object definitions where possible
- Run `eslint --fix` after changes

## Models

Sequelize-based in `models/`. Associations in `.associate()` method. Field definitions on single lines.

## Apps

Separate Express apps in `apps/`: integration-hub, public, internal, user, mobile, rate-services.

## Testing

Jest with `--runInBand`. Factories via `#tests/factories`. Test files named `*.spec.js`.

## Key Directories

`models/`, `procedures/`, `queries/`, `services/`, `middleware/`, `helpers/`, `library/utils/`, `queues-v2/`, `scheduled-jobs/`
