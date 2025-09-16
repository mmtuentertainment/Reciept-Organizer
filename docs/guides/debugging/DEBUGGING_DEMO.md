# 🐛 Debugging Demonstration - Receipt Organizer

## Current Debugging Session Active

**🔥 Live Debug Server Running:**
- **URL**: http://localhost:3005
- **Node.js Inspector**:
  - Primary: `ws://127.0.0.1:9229/89f594bd-89f7-44cb-8b8f-877a1471ef10`
  - Secondary: `ws://127.0.0.1:9230/49513f13-21e2-4e30-8e1c-49d5973c4bf8`

---

## 🎯 How to Use the Debugging Setup

### **Method 1: VS Code Debugging (Recommended)**

1. **Open VS Code** in the project root: `/home/matt/FINAPP/Receipt Organizer`

2. **Access Debug Panel**: `Ctrl+Shift+D` (Windows/Linux) or `⇧+⌘+D` (macOS)

3. **Select Configuration**: Choose one of these from the dropdown:
   - **"Next.js Web: debug server-side"** - Debug API routes and server code
   - **"Next.js Web: debug client-side"** - Debug React components in Chrome
   - **"Next.js Web: debug full stack"** - Debug both client and server

4. **Start Debugging**: Press `F5` or click the green play button

5. **Set Breakpoints**: Click in the gutter next to line numbers in your files

### **Method 2: Chrome DevTools**

#### For Server-Side Debugging:
1. **Open Chrome** and go to: `chrome://inspect`
2. **Configure** (if needed): Click "Configure" and add `localhost:9229` and `localhost:9230`
3. **Find Target**: Look for "Next.js" under "Remote Target"
4. **Click "inspect"** to open dedicated DevTools window
5. **Go to Sources tab** to set breakpoints

#### For Client-Side Debugging:
1. **Open** http://localhost:3005 in Chrome
2. **Open DevTools**: `Ctrl+Shift+J` (Windows/Linux) or `⌘+⌥+I` (macOS)
3. **Go to Sources tab**
4. **Find files**: Press `Ctrl+P` (Windows/Linux) or `⌘+P` (macOS) to search files
5. **Set breakpoints** by clicking line numbers

---

## 🔍 Debugging Points Added to Code

### **Server-Side Debug Points**

**File**: `apps/web/app/api/receipts/upload/route.ts:13`
```typescript
// 🐛 DEBUG: API endpoint hit
debugger; // This will pause execution in debugger
console.log('📸 Receipt upload API called at:', new Date().toISOString())
```

**Line 21** - Authentication check:
```typescript
// 🐛 DEBUG: Check authentication result
console.log('👤 User authentication:', { userId: user?.id, hasError: !!authError })
```

### **Client-Side Debug Points**

**File**: `apps/web/components/receipts/receipt-capture.tsx:83`
```typescript
// 🐛 DEBUG: Client-side file upload started
debugger; // This will pause execution in browser DevTools
console.log('🔄 Client: Starting file upload', {
  fileName: file.name,
  fileSize: file.size,
  fileType: file.type
})
```

**Line 101** - Form data preparation:
```typescript
// 🐛 DEBUG: Form data preparation
console.log('📝 Client: Form data prepared', {
  hasFile: uploadFormData.has('file'),
  categoryId: formData.category_id,
  autoOCR: true
})
```

---

## 🎮 Interactive Debugging Workflow

### **Step 1: Test Client-Side Debugging**

1. **Open** http://localhost:3005 in Chrome with DevTools open
2. **Navigate** to the receipts page
3. **Click "Capture Receipt"** or upload button
4. **Select a file** - execution will pause at the `debugger;` statement
5. **Inspect variables**: Hover over variables to see their values
6. **Step through code**: Use F10 (step over) or F11 (step into)

### **Step 2: Test Server-Side Debugging**

1. **Connect Chrome to Node.js**: Go to `chrome://inspect` and click "inspect"
2. **Upload a file** from the client
3. **Server will pause** at the API route debugger statement
4. **Examine request data**: Check the `request`, `formData`, and `user` variables
5. **Step through the upload process**

### **Step 3: Full-Stack Debugging**

1. **Use VS Code "Full Stack" configuration** for simultaneous debugging
2. **Set breakpoints** in both client and server files
3. **Trace data flow** from client upload → API route → services → database

---

## 🔧 Debugging Scenarios to Try

### **Scenario 1: File Upload Issue**
```typescript
// In receipt-capture.tsx, examine:
- file.name, file.size, file.type
- uploadFormData contents
- API response data
```

### **Scenario 2: Authentication Problem**
```typescript
// In upload/route.ts, check:
- user object structure
- authError details
- Supabase client status
```

### **Scenario 3: OCR Processing**
```typescript
// Add breakpoints in:
- /lib/services/ocr-service.ts
- Google Vision API calls
- OCR response parsing
```

### **Scenario 4: Database Issues**
```typescript
// Debug in:
- /lib/services/receipt-upload-service.ts
- Supabase database operations
- File storage operations
```

---

## 🎯 Practical Debugging Tips

### **Console Output Tracking**
Watch for these debug messages in the console:
```
📸 Receipt upload API called at: 2025-01-14T03:40:03.611Z
👤 User authentication: { userId: "abc123", hasError: false }
🔄 Client: Starting file upload { fileName: "receipt.jpg", fileSize: 245760, fileType: "image/jpeg" }
📝 Client: Form data prepared { hasFile: true, categoryId: "cat_123", autoOCR: true }
```

### **Breakpoint Strategy**
1. **Entry Points**: Set breakpoints at function entry
2. **Decision Points**: Before if/else statements
3. **Error Handlers**: In catch blocks and error conditions
4. **API Boundaries**: Before and after external calls

### **Variable Inspection**
- **Hover** over variables to see values
- **Watch Panel**: Add variables to continuous monitoring
- **Call Stack**: See the complete execution path
- **Scope**: Examine local, closure, and global variables

---

## 🚀 Advanced Features

### **Conditional Breakpoints**
Right-click breakpoint → Add condition:
```javascript
file.size > 1000000  // Only break for files larger than 1MB
user.id === "specific-user-id"  // Only break for specific user
```

### **Log Points**
Instead of adding `console.log`, use logpoints:
```javascript
// Right-click line number → Add Logpoint
"File uploaded: {file.name}, Size: {file.size}"
```

### **Performance Debugging**
- **Chrome DevTools Performance tab** for client-side performance
- **Network tab** to monitor API calls
- **Memory tab** for memory leak detection

---

## 🎬 Live Demo Ready!

**Your debugging environment is now active and ready for demonstration:**

✅ **VS Code configurations** loaded
✅ **Debug server** running on port 3005
✅ **Node.js Inspector** active on ports 9229/9230
✅ **Debug breakpoints** added to key functions
✅ **Chrome DevTools** ready for connection

**Next Steps:**
1. Open http://localhost:3005 in Chrome
2. Open VS Code debug panel (`Ctrl+Shift+D`)
3. Try uploading a receipt to trigger debug breakpoints
4. Explore the debugging experience!

---

*Happy debugging! 🐛→✨*