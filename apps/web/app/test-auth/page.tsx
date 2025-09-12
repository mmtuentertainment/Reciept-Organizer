'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'

export default function TestAuthPage() {
  const [status, setStatus] = useState<string>('Not tested')
  const [details, setDetails] = useState<any>(null)
  const [loading, setLoading] = useState(false)
  const supabase = createClient()

  const testConnection = async () => {
    setLoading(true)
    setStatus('Testing...')
    setDetails(null)

    try {
      // Test 1: Basic connection
      const { data: sessionData, error: sessionError } = await supabase.auth.getSession()
      
      if (sessionError) {
        setStatus('Session Error')
        setDetails({ sessionError: sessionError.message })
        setLoading(false)
        return
      }

      // Test 2: Try to sign up with test credentials
      const testEmail = `test${Date.now()}@example.com`
      const { data, error } = await supabase.auth.signUp({
        email: testEmail,
        password: 'testpassword123',
      })

      if (error) {
        setStatus('Auth Error')
        setDetails({
          error: error.message,
          code: error.status,
          details: error,
        })
      } else {
        setStatus('Success')
        setDetails({
          message: 'Connection successful!',
          user: data.user?.email,
          session: data.session,
        })
        
        // Clean up test user
        if (data.session) {
          await supabase.auth.signOut()
        }
      }
    } catch (err: any) {
      setStatus('Network Error')
      setDetails({
        error: err.message,
        type: 'Network/CORS issue',
        suggestion: 'Check if Supabase URL is accessible and CORS is configured',
      })
    } finally {
      setLoading(false)
    }
  }

  const testHealthCheck = async () => {
    setLoading(true)
    try {
      const response = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/auth/v1/health`, {
        method: 'GET',
      })
      
      const data = await response.text()
      setStatus('Health Check')
      setDetails({
        status: response.status,
        statusText: response.statusText,
        response: data,
        url: `${process.env.NEXT_PUBLIC_SUPABASE_URL}/auth/v1/health`,
      })
    } catch (err: any) {
      setStatus('Health Check Failed')
      setDetails({
        error: err.message,
        url: process.env.NEXT_PUBLIC_SUPABASE_URL,
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="container mx-auto py-10">
      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <CardTitle>Supabase Authentication Test</CardTitle>
          <CardDescription>
            Test the connection to your Supabase authentication service
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center space-x-4">
            <Badge variant={status === 'Success' ? 'default' : status === 'Not tested' ? 'outline' : 'destructive'}>
              {status}
            </Badge>
            <span className="text-sm text-muted-foreground">
              URL: {process.env.NEXT_PUBLIC_SUPABASE_URL}
            </span>
          </div>

          <div className="space-x-4">
            <Button onClick={testConnection} disabled={loading}>
              {loading ? 'Testing...' : 'Test Authentication'}
            </Button>
            <Button onClick={testHealthCheck} disabled={loading} variant="outline">
              {loading ? 'Checking...' : 'Health Check'}
            </Button>
          </div>

          {details && (
            <div className="mt-4 p-4 bg-muted rounded-lg">
              <pre className="text-xs overflow-auto">
                {JSON.stringify(details, null, 2)}
              </pre>
            </div>
          )}

          <div className="mt-6 p-4 bg-blue-50 dark:bg-blue-950 rounded-lg">
            <h3 className="font-semibold mb-2">Troubleshooting Tips:</h3>
            <ul className="text-sm space-y-1 text-muted-foreground">
              <li>• Ensure email authentication is enabled in Supabase Dashboard</li>
              <li>• Check that your Supabase URL and anon key are correct</li>
              <li>• Verify Site URL is set to http://localhost:3000 in Supabase Auth settings</li>
              <li>• Check Redirect URLs include http://localhost:3000/* in Supabase</li>
              <li>• Ensure no firewall or VPN is blocking the connection</li>
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}