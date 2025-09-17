'use client';

import { useEffect, useState, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';

function OAuthSuccessContent() {
  const searchParams = useSearchParams();
  const [status, setStatus] = useState('Processing...');
  
  useEffect(() => {
    const provider = searchParams.get('provider');
    const session = searchParams.get('session');
    
    if (provider && session) {
      setStatus(`Successfully authenticated with ${provider}!`);
      
      // For mobile app, try to open deep link
      const deepLink = `receiptorganizer://oauth/success?session=${session}&provider=${provider}`;

      // Validate deep link format and try to open the app
      if (/^receiptorganizer:\/\//.test(deepLink)) {
        setTimeout(() => {
          window.location.assign(deepLink);
        }, 1000);
      }
      
      // Fallback message after 3 seconds
      setTimeout(() => {
        setStatus(`Authentication successful! You can close this window and return to the Receipt Organizer app.`);
      }, 3000);
    } else {
      setStatus('Authentication completed. You can close this window.');
    }
  }, [searchParams]);

  return (
    <div style={{ 
      padding: '2rem', 
      textAlign: 'center',
      fontFamily: 'system-ui, -apple-system, sans-serif'
    }}>
      <h1 style={{ color: '#10b981' }}>✅ Authentication Successful!</h1>
      <p>{status}</p>
      <div style={{ marginTop: '2rem' }}>
        <p style={{ color: '#6b7280', fontSize: '0.9rem' }}>
          If the app doesn't open automatically, you can close this window and return to the Receipt Organizer app.
        </p>
      </div>
    </div>
  );
}

export default function OAuthSuccess() {
  return (
    <Suspense fallback={
      <div style={{ 
        padding: '2rem', 
        textAlign: 'center',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}>
        <h1>Loading...</h1>
      </div>
    }>
      <OAuthSuccessContent />
    </Suspense>
  );
}