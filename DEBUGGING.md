# Debugging Guide for Receipt Organizer

## Overview
The Receipt Organizer application is now configured with comprehensive debugging capabilities for both client-side and server-side code.

## VS Code Debugging Configurations

The following debug configurations are available in VS Code (accessible via `Ctrl+Shift+D`):

### 1. Next.js Web: debug server-side
- **Purpose**: Debug Node.js backend code (API routes, server components)
- **Usage**: Select this configuration and press F5
- **Features**: Full server-side debugging with breakpoints

### 2. Next.js Web: debug client-side
- **Purpose**: Debug React components and client-side JavaScript
- **Browser**: Chrome (default)
- **URL**: http://localhost:3002
- **Features**: Full client-side debugging in Chrome DevTools

### 3. Next.js Web: debug client-side (Firefox)
- **Purpose**: Alternative client-side debugging using Firefox
- **Browser**: Firefox
- **Features**: Firefox DevTools integration

### 4. Next.js Web: debug full stack
- **Purpose**: Debug both client and server code simultaneously
- **Features**: Complete full-stack debugging experience

### 5. React Native: debug
- **Purpose**: Debug the mobile React Native application
- **Platform**: Android (configured)

## Command Line Debugging

### Development Server with Debugging
```bash
# Start with debugging enabled
npm run dev:debug

# Expected output:
# Debugger listening on ws://127.0.0.1:9229/...
# Debugger listening on ws://127.0.0.1:9230/...
```

### Browser DevTools Access

#### For Server-Side Debugging:
1. Open Chrome
2. Go to `chrome://inspect`
3. Click "Configure" and ensure `localhost:9229` and `localhost:9230` are listed
4. Find your Next.js application under "Remote Target"
5. Click "inspect"

#### For Client-Side Debugging:
1. Open http://localhost:3002
2. Open Chrome DevTools (`Ctrl+Shift+J`)
3. Go to Sources tab
4. Search for files with `Ctrl+P`
5. Source files have paths starting with `webpack://_N_E/./`

## Debugging Features

### Breakpoints
- Set breakpoints in VS Code or browser DevTools
- Use `debugger;` statements in your code
- Conditional breakpoints available

### React Developer Tools
Install the browser extension for React-specific debugging:
- Component inspection
- Props and state editing
- Performance profiling

### Server-Side Debugging
- API routes: `/app/api/**/*.ts`
- Server components and actions
- Database queries and external API calls

### Client-Side Debugging
- React components: `/components/**/*.tsx`
- Pages: `/app/**/*.tsx`
- Hooks and utilities: `/lib/**/*.ts`

## Project Structure for Debugging

```
apps/web/
├── app/                    # Next.js App Router
│   ├── api/               # Server-side API routes
│   ├── receipts/          # Receipt management pages
│   └── layout.tsx         # Root layout
├── components/            # React components
│   ├── receipts/         # Receipt-specific components
│   └── ui/               # Shared UI components
├── lib/                   # Utilities and services
│   └── services/         # Business logic services
└── .vscode/
    └── launch.json       # VS Code debug configurations
```

## Common Debugging Scenarios

### 1. API Route Issues
- Use "Next.js Web: debug server-side" configuration
- Set breakpoints in `/app/api/` files
- Inspect request/response objects

### 2. Component Rendering Issues
- Use "Next.js Web: debug client-side" configuration
- Set breakpoints in component files
- Use React Developer Tools

### 3. Full-Stack Data Flow
- Use "Next.js Web: debug full stack" configuration
- Trace data from API to component rendering

### 4. OCR Processing Issues
- Debug in `/lib/services/ocr-service.ts`
- Set breakpoints in Google Vision API calls
- Inspect OCR response data

### 5. File Upload Issues
- Debug in `/lib/services/receipt-upload-service.ts`
- Trace file processing pipeline
- Monitor Supabase storage operations

## Tips

1. **Performance**: Use browser DevTools Performance tab for client-side performance issues
2. **Network**: Monitor API calls in Network tab
3. **Console**: Use `console.log()` strategically, but prefer breakpoints
4. **Source Maps**: Full source map support for both TypeScript and React
5. **Hot Reload**: Debugging works with Next.js hot reload

## Troubleshooting

### Port Conflicts
If port 3002 is in use:
```bash
# Kill existing processes
pkill -f "next dev"

# Or use a different port
npm run dev:debug -- -p 3003
```

### Debugger Not Connecting
1. Ensure VS Code has the Node.js debugger extension
2. Check that `cross-env` is installed
3. Verify launch.json paths are correct for monorepo structure

### Source Maps Not Loading
1. Restart the development server
2. Clear browser cache
3. Check VS Code workspace folder is correct

---

*This debugging setup provides comprehensive development and troubleshooting capabilities for the Receipt Organizer application.*