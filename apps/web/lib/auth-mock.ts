// Mock authentication for demo purposes when Supabase is not available
export const mockAuth = {
  signUp: async (email: string, password: string, name?: string) => {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // Store in localStorage for demo
    const user = {
      id: `user_${Date.now()}`,
      email,
      name: name || email.split('@')[0],
      created_at: new Date().toISOString()
    }
    
    localStorage.setItem('mock_user', JSON.stringify(user))
    localStorage.setItem('mock_auth', 'true')
    
    return { user, error: null }
  },

  signIn: async (email: string, password: string) => {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // For demo, accept any credentials
    const user = {
      id: `user_${Date.now()}`,
      email,
      name: email.split('@')[0],
      created_at: new Date().toISOString()
    }
    
    localStorage.setItem('mock_user', JSON.stringify(user))
    localStorage.setItem('mock_auth', 'true')
    
    return { user, error: null }
  },

  signOut: async () => {
    localStorage.removeItem('mock_user')
    localStorage.removeItem('mock_auth')
    return { error: null }
  },

  getUser: () => {
    const userStr = localStorage.getItem('mock_user')
    const isAuth = localStorage.getItem('mock_auth')
    
    if (isAuth && userStr) {
      return JSON.parse(userStr)
    }
    return null
  }
}