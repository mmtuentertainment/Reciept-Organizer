#!/bin/bash

# Supabase Project Initialization Script
# This script sets up a local Supabase instance for development

set -e

echo "🚀 Initializing Supabase for Receipt Organizer..."

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it first:"
    echo "   brew install supabase/tap/supabase"
    echo "   or"
    echo "   npm install -g supabase"
    exit 1
fi

# Check if Docker is running (required for local Supabase)
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Initialize Supabase project if not already initialized
if [ ! -f "supabase/config.toml" ]; then
    echo "📦 Initializing new Supabase project..."
    supabase init
fi

# Start local Supabase
echo "🔧 Starting local Supabase instance..."
supabase start

# Get the local credentials
echo ""
echo "✅ Supabase is running locally!"
echo ""
echo "📋 Local Development Credentials:"
echo "================================="
supabase status

# Apply migrations
echo ""
echo "🗄️ Applying database migrations..."
supabase db push

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy the Anon key and API URL from above"
echo "2. Create apps/mobile/.env file with these values"
echo "3. Run the Flutter app with: flutter run --dart-define-from-file=.env"
echo ""
echo "🔗 Access points:"
echo "- Studio UI: http://localhost:54323"
echo "- API: http://localhost:54321"
echo "- Database: postgresql://postgres:postgres@localhost:54322/postgres"