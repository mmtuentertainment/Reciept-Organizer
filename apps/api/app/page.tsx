export default function Home() {
  return (
    <div style={{ 
      padding: '2rem', 
      fontFamily: 'system-ui, -apple-system, sans-serif',
      maxWidth: '800px',
      margin: '0 auto'
    }}>
      <div style={{ 
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white',
        padding: '2rem',
        borderRadius: '12px',
        marginBottom: '2rem'
      }}>
        <h1 style={{ margin: 0, fontSize: '2.5rem' }}>📱 Receipt Organizer API</h1>
        <p style={{ marginTop: '0.5rem', opacity: 0.9 }}>
          Backend services for Receipt Organizer mobile app
        </p>
      </div>

      <div style={{ 
        background: '#f7f7f7', 
        padding: '1.5rem', 
        borderRadius: '8px',
        marginBottom: '2rem'
      }}>
        <h2 style={{ marginTop: 0, color: '#333' }}>🚀 API Status</h2>
        <p style={{ color: '#666' }}>
          <strong style={{ color: '#4CAF50' }}>● Online</strong> - All systems operational
        </p>
        <p style={{ color: '#666', margin: 0 }}>
          Version: 1.0.0 | Environment: Production
        </p>
      </div>

      <div style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: '#333' }}>📍 Available Endpoints</h2>
        <div style={{ background: 'white', borderRadius: '8px', overflow: 'hidden' }}>
          <div style={{ padding: '1rem', borderBottom: '1px solid #eee' }}>
            <code style={{ color: '#e91e63' }}>GET /api/health</code>
            <p style={{ margin: '0.5rem 0 0', color: '#666' }}>
              Health check endpoint - Returns system status
            </p>
          </div>
          <div style={{ padding: '1rem', borderBottom: '1px solid #eee' }}>
            <code style={{ color: '#e91e63' }}>POST /api/validate/csv</code>
            <p style={{ margin: '0.5rem 0 0', color: '#666' }}>
              Validate CSV data for QuickBooks/Xero compatibility
            </p>
          </div>
          <div style={{ padding: '1rem', borderBottom: '1px solid #eee' }}>
            <code style={{ color: '#e91e63' }}>GET /api/oauth/quickbooks</code>
            <p style={{ margin: '0.5rem 0 0', color: '#666' }}>
              QuickBooks OAuth integration endpoints
            </p>
          </div>
          <div style={{ padding: '1rem', borderBottom: '1px solid #eee' }}>
            <code style={{ color: '#e91e63' }}>GET /api/oauth/xero</code>
            <p style={{ margin: '0.5rem 0 0', color: '#666' }}>
              Xero OAuth integration endpoints
            </p>
          </div>
          <div style={{ padding: '1rem' }}>
            <code style={{ color: '#e91e63' }}>POST /api/export</code>
            <p style={{ margin: '0.5rem 0 0', color: '#666' }}>
              Export receipts with platform-specific formatting
            </p>
          </div>
        </div>
      </div>

      <div style={{ marginBottom: '2rem' }}>
        <h2 style={{ color: '#333' }}>🔒 Authentication</h2>
        <p style={{ color: '#666' }}>
          This API uses Supabase authentication. Include your API key in the Authorization header:
        </p>
        <pre style={{ 
          background: '#2d2d2d', 
          color: '#f8f8f2',
          padding: '1rem',
          borderRadius: '4px',
          overflow: 'auto'
        }}>
          {`Authorization: Bearer YOUR_API_KEY`}
        </pre>
      </div>

      <div style={{ 
        background: '#fff3cd', 
        border: '1px solid #ffc107',
        borderRadius: '8px',
        padding: '1rem',
        marginBottom: '2rem'
      }}>
        <h3 style={{ margin: 0, color: '#856404' }}>📖 Documentation</h3>
        <p style={{ margin: '0.5rem 0 0', color: '#856404' }}>
          For detailed API documentation and integration guides, please refer to the project repository.
        </p>
      </div>

      <footer style={{ 
        textAlign: 'center', 
        padding: '2rem 0',
        borderTop: '1px solid #eee',
        color: '#666'
      }}>
        <p style={{ margin: 0 }}>
          Receipt Organizer © 2025 | Powered by Next.js & Vercel
        </p>
        <p style={{ margin: '0.5rem 0 0', fontSize: '0.9rem' }}>
          <a href="/api/health" style={{ color: '#667eea' }}>Check API Health</a>
        </p>
      </footer>
    </div>
  );
}