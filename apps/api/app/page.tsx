export default function Home() {
  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>Receipt Organizer API</h1>
      <p>CSV validation API for QuickBooks and Xero</p>
      <div style={{ marginTop: '2rem' }}>
        <h2>Available Endpoints:</h2>
        <ul>
          <li>/api/health - Health check</li>
          <li>/api/validate/csv - CSV validation</li>
          <li>/api/oauth/quickbooks - QuickBooks OAuth</li>
          <li>/api/oauth/xero - Xero OAuth</li>
        </ul>
      </div>
    </div>
  );
}