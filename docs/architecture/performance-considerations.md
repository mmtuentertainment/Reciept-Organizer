# Performance Considerations

### Authentication Performance Targets

| Operation | Target | Critical | Notes |
|-----------|--------|----------|-------|
| Initial Load | <100ms | <200ms | Check cached session |
| Login | <1s | <2s | Including network |
| Token Refresh | <500ms | <1s | Background operation |
| Biometric Auth | <2s | <3s | Including UI prompt |
| Session Check | <50ms | <100ms | Local validation |

### Optimization Strategies

1. **Eager Token Refresh**: Refresh 5 minutes before expiry
2. **Session Caching**: Store validated sessions in memory
3. **Parallel Initialization**: Load auth state while UI renders
4. **Lazy OAuth Setup**: Only initialize OAuth when needed
5. **Request Deduplication**: Prevent multiple simultaneous refreshes
