"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { createClient } from "@/lib/supabase/client"

export default function AuthCallbackPage() {
  const router = useRouter()
  const supabase = createClient()

  useEffect(() => {
    const handleCallback = async () => {
      // Check if we have a session after email confirmation
      const { data: { session } } = await supabase.auth.getSession()

      if (session) {
        // User is authenticated, redirect to dashboard
        router.push("/dashboard")
      } else {
        // No session, redirect to login
        router.push("/login")
      }
    }

    handleCallback()
  }, [router, supabase])

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h2 className="text-2xl font-semibold mb-2">Verifying your email...</h2>
        <p className="text-muted-foreground">Please wait while we confirm your account.</p>
      </div>
    </div>
  )
}