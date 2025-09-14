'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

// Password validation function
function validatePassword(password: string): { isValid: boolean; errors: string[] } {
  const errors: string[] = []

  // Check minimum length (8 characters)
  if (password.length < 8) {
    errors.push('Password must be at least 8 characters long')
  }

  // Check for uppercase letter
  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter')
  }

  // Check for lowercase letter
  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter')
  }

  // Check for number
  if (!/\d/.test(password)) {
    errors.push('Password must contain at least one number')
  }

  // Check for special character
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
    errors.push('Password must contain at least one special character')
  }

  return {
    isValid: errors.length === 0,
    errors
  }
}

export async function signup(formData: FormData) {
  const supabase = await createClient()

  // Get form data
  const email = formData.get('email') as string
  const password = formData.get('password') as string
  const confirmPassword = formData.get('confirmPassword') as string

  // Validate email
  if (!email || !email.includes('@')) {
    return { error: 'Please enter a valid email address' }
  }

  // Check passwords match
  if (password !== confirmPassword) {
    return { error: 'Passwords do not match' }
  }

  // Validate password strength
  const passwordValidation = validatePassword(password)
  if (!passwordValidation.isValid) {
    return { error: passwordValidation.errors.join('. ') }
  }

  // Attempt signup
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      emailRedirectTo: `${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3002'}/auth/callback`,
    },
  })

  if (error) {
    console.error('Signup error:', error)
    return { error: error.message }
  }

  if (data?.user?.identities?.length === 0) {
    return { error: 'This email is already registered. Please sign in instead.' }
  }

  // Success - return success message (don't redirect yet)
  return {
    success: true,
    message: 'Account created successfully! Please check your email to verify your account.'
  }
}

export async function login(formData: FormData) {
  const supabase = await createClient()

  const email = formData.get('email') as string
  const password = formData.get('password') as string

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    return { error: error.message }
  }

  revalidatePath('/', 'layout')
  redirect('/dashboard')
}

export async function signInWithGoogle() {
  const supabase = await createClient()

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3002'}/auth/callback`,
    },
  })

  if (error) {
    return { error: error.message }
  }

  if (data.url) {
    redirect(data.url)
  }
}