'use client';

import { useEffect } from 'react';

export default function XeroAuth() {
  useEffect(() => {
    // Fetch the auth URL and redirect
    fetch('/api/auth/xero')
      .then(res => res.json())
      .then(data => {
        if (data.success && data.authUrl) {
          // Store session info in localStorage for later
          localStorage.setItem('xero_session', JSON.stringify({
            sessionId: data.sessionId,
            sessionToken: data.sessionToken,
          }));
          // Redirect to Xero
          window.location.href = data.authUrl;
        } else {
          console.error('Failed to get auth URL:', data);
        }
      })
      .catch(err => {
        console.error('Error:', err);
      });
  }, []);

  return (
    <div style={{ padding: '2rem', textAlign: 'center' }}>
      <h1>Redirecting to Xero...</h1>
      <p>Please wait while we redirect you to Xero for authentication.</p>
    </div>
  );
}