#!/bin/bash

# Receipt Organizer - Authentication Setup Script
# This script helps set up the authentication environment

echo "🔐 Receipt Organizer - Authentication Setup"
echo "==========================================="
echo ""

# Check if .env.local exists
if [ -f .env.local ]; then
    echo "⚠️  .env.local already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
fi

# Copy the example file
cp .env.local.example .env.local
echo "✅ Created .env.local from template"
echo ""

# Prompt for Supabase URL
echo "📌 Enter your Supabase project URL"
echo "   (Found in Dashboard → Settings → API)"
read -p "URL: " SUPABASE_URL

# Prompt for Supabase Anon Key
echo ""
echo "🔑 Enter your Supabase anon key"
echo "   (Found in Dashboard → Settings → API → anon public)"
read -p "Key: " SUPABASE_ANON_KEY

# Update the .env.local file
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|https://your-project-ref.supabase.co|$SUPABASE_URL|g" .env.local
    sed -i '' "s|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-anon-key-here|$SUPABASE_ANON_KEY|g" .env.local
else
    # Linux
    sed -i "s|https://your-project-ref.supabase.co|$SUPABASE_URL|g" .env.local
    sed -i "s|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-anon-key-here|$SUPABASE_ANON_KEY|g" .env.local
fi

echo ""
echo "✅ Configuration updated!"
echo ""

# Optional: Prompt for service role key
read -p "Do you want to add the service role key? (for production) (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔐 Enter your Supabase service role key"
    echo "   (Found in Dashboard → Settings → API → service_role)"
    echo "   ⚠️  WARNING: Keep this key secret!"
    read -s -p "Key: " SERVICE_ROLE_KEY
    echo ""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-service-role-key-here|$SERVICE_ROLE_KEY|g" .env.local
    else
        sed -i "s|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-service-role-key-here|$SERVICE_ROLE_KEY|g" .env.local
    fi
    echo "✅ Service role key added"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run 'npm install' to install dependencies"
echo "2. Run 'npm run dev' to start the development server"
echo "3. Visit http://localhost:3002 to see the app"
echo ""
echo "📚 See README.md for more information"