# User Interface Enhancement Goals

### Integration with Existing UI

New authentication UI elements will integrate with existing patterns:
- **Web (Next.js)**: Use shadcn/ui components for forms, buttons, and modals to match existing dashboard
- **Mobile (Flutter)**: Follow Material Design 3 patterns already established in capture screens
- **Native (React Native)**: Implement NativeWind styling consistent with existing tab navigation

### Modified/New Screens and Views

**New Screens:**
- Login/Sign-up screen (all platforms)
- Password reset screen (all platforms)
- User profile management screen (all platforms)
- OAuth callback handler (web-specific)

**Modified Screens:**
- Main navigation - Add user avatar/menu (all platforms)
- Settings screen - Add authentication section (mobile/native)
- Dashboard header - Add user info widget (web)

### UI Consistency Requirements
- All auth forms must use existing validation error patterns
- Loading states during auth operations must match existing loading indicators
- Success/error messages must use current toast/snackbar implementations
- Color schemes and typography must remain consistent with Phase 1 UI
