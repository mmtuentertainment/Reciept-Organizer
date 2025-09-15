#!/bin/bash

# Clear Next.js cache to prevent env issues
rm -rf .next

# Export production Supabase credentials
export NEXT_PUBLIC_SUPABASE_URL=https://xbadaalqaeszooyxuoac.supabase.co
export NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiYWRhYWxxYWVzem9veXh1b2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3ODE1MzAsImV4cCI6MjA3MzM1NzUzMH0.PY-aQ6bjYUPaTL2o2twviFf5AJTSYR0gyKUkQb08OGc

# Start the dev server
npm run dev