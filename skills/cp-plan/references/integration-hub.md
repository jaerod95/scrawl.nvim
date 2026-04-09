# integration-hub

Node.js 22, CommonJS (Babel compiled), BullMQ. Manages scheduled integrations for the Applause platform.

## File Organization

- One function per file in `index.js`, similar to api-gateway
- Source in `src/`, compiled to `dist/`

## Integration Structure

Each integration in `src/integrations/` (e.g., `jobber-api/`):

```
src/integrations/{name}/
├── index.js          # initialize() export, registers handlers
├── actions/          # job handlers and scheduled tasks
└── specs/mocks/      # test fixtures
```

## Library Structure

- `src/library/packages/` — wrappers around external libraries (bullmq, playwright, redis, undici, imap, etc.)
- `src/library/services/` — business logic services
- `src/library/utils/` — utility functions (async, converters, formatters, pipe, strings)
- `src/library/errors/` — custom error definitions

## Apps

Express apps in `src/apps/`: admin, api-gateway, webhooks.

## Job Processing

BullMQ for job scheduling with a monitoring service.

## Key Directories

`src/integrations/`, `src/library/packages/`, `src/library/services/`, `src/library/utils/`, `src/apps/`
