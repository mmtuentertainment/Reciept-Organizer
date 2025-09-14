# High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Applications                    │
├─────────────────┬─────────────────┬─────────────────────────┤
│   Flutter Web   │    Next.js      │   React Native          │
│   (Riverpod)    │  (React Context)│  (React Context)        │
└────────┬────────┴────────┬────────┴────────┬───────────────┘
         │                 │                  │
         ├─────────────────┼──────────────────┤
         │          Auth SDK Layer            │
         │  ┌──────────────────────────────┐  │
         │  │ Platform-Specific Adapters   │  │
         │  ├──────────────────────────────┤  │
         │  │ Token Storage Abstraction    │  │
         │  ├──────────────────────────────┤  │
         │  │ Session Management Core      │  │
         │  └──────────────────────────────┘  │
         │                 │                  │
         └─────────────────┼──────────────────┘
                          │
                    ┌─────▼─────┐
                    │ Supabase  │
                    │   Cloud    │
                    ├───────────┤
                    │ Auth      │
                    │ Database  │
                    │ Storage   │
                    │ Realtime  │
                    └───────────┘
```
