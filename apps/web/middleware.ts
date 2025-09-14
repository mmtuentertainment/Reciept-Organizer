import { type NextRequest, NextResponse } from 'next/server'
import { updateSession } from '@/lib/supabase/middleware'

export async function middleware(request: NextRequest) {
  // Get the pathname of the request
  const { pathname } = request.nextUrl

  console.log('🔍 Middleware:', pathname)

  // Skip middleware for static assets and API routes
  if (
    pathname.startsWith('/_next/') ||
    pathname.startsWith('/api/') ||
    pathname.includes('.')
  ) {
    return NextResponse.next()
  }

  // Update user's session and get the response
  const response = await updateSession(request)

  // Protected routes that require authentication
  const protectedRoutes = ['/dashboard', '/receipts', '/profile', '/settings']
  const isProtectedRoute = protectedRoutes.some(route => pathname.startsWith(route))

  // Auth routes that should redirect if already logged in
  const authRoutes = ['/login', '/signup']
  const isAuthRoute = authRoutes.some(route => pathname.startsWith(route))

  if (isProtectedRoute) {
    console.log('🔐 Protected route accessed:', pathname)

    // Check if user is authenticated by looking for valid session cookie
    const supabaseAuthToken = request.cookies.get('sb-xbadaalqaeszooyxuoac-auth-token')
    console.log('🍪 Auth cookie present:', !!supabaseAuthToken?.value)

    if (!supabaseAuthToken?.value) {
      console.log('❌ No auth cookie, redirecting to login')
      // No auth token, redirect to login
      const loginUrl = new URL('/login', request.url)
      loginUrl.searchParams.set('redirectTo', pathname)
      return NextResponse.redirect(loginUrl)
    }

    // Check if the auth token is not just an empty object or invalid
    try {
      let tokenData

      // Handle both base64-encoded and JSON cookie formats
      if (supabaseAuthToken.value.startsWith('base64-')) {
        // Decode base64-encoded cookie
        const base64Data = supabaseAuthToken.value.replace('base64-', '')
        const decodedData = Buffer.from(base64Data, 'base64').toString('utf-8')
        tokenData = JSON.parse(decodedData)
        console.log('🔑 Decoded base64 token successfully')
      } else {
        // Parse as JSON directly (fallback for old format)
        tokenData = JSON.parse(supabaseAuthToken.value)
        console.log('🔑 Parsed JSON token directly')
      }

      console.log('🔑 Token has access_token:', !!tokenData.access_token)

      if (!tokenData.access_token) {
        console.log('❌ Invalid token, redirecting to login')
        const loginUrl = new URL('/login', request.url)
        loginUrl.searchParams.set('redirectTo', pathname)
        return NextResponse.redirect(loginUrl)
      }

      console.log('✅ Valid token, allowing access to', pathname)
    } catch (error) {
      console.log('❌ Token parse error:', error, 'redirecting to login')
      // Invalid token format, redirect to login
      const loginUrl = new URL('/login', request.url)
      loginUrl.searchParams.set('redirectTo', pathname)
      return NextResponse.redirect(loginUrl)
    }
  }

  if (isAuthRoute) {
    console.log('🔐 Auth route accessed:', pathname)

    // Check if user might be authenticated
    const supabaseAuthToken = request.cookies.get('sb-xbadaalqaeszooyxuoac-auth-token')

    if (supabaseAuthToken?.value) {
      try {
        let tokenData

        // Handle both base64-encoded and JSON cookie formats
        if (supabaseAuthToken.value.startsWith('base64-')) {
          // Decode base64-encoded cookie
          const base64Data = supabaseAuthToken.value.replace('base64-', '')
          const decodedData = Buffer.from(base64Data, 'base64').toString('utf-8')
          tokenData = JSON.parse(decodedData)
        } else {
          // Parse as JSON directly (fallback for old format)
          tokenData = JSON.parse(supabaseAuthToken.value)
        }

        if (tokenData.access_token) {
          console.log('✅ User already authenticated, redirecting to dashboard')
          // User appears to be authenticated, redirect to dashboard or redirectTo
          const redirectTo = request.nextUrl.searchParams.get('redirectTo')
          const redirectUrl = redirectTo || '/dashboard'
          return NextResponse.redirect(new URL(redirectUrl, request.url))
        }
      } catch {
        // Invalid token, let them proceed to auth pages
        console.log('🔐 Invalid auth token, staying on auth page')
      }
    }
  }

  return response
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     * - api routes
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}