#!/bin/bash
set -e

echo "🍄 Shroom Docker Setup"
echo "====================="
echo ""

# Generate a secret key if needed
if command -v mix &> /dev/null; then
    echo "Generating SECRET_KEY_BASE..."
    SECRET_KEY=$(mix phx.gen.secret)
    echo ""
    echo "✅ Generated secret key: $SECRET_KEY"
    echo ""
    echo "⚠️  IMPORTANT: Update docker-compose.prod.yml with this key!"
    echo "   Replace 'CHANGE_ME_IN_PRODUCTION_USE_mix_phx_gen_secret_TO_GENERATE'"
    echo "   with: $SECRET_KEY"
    echo ""
else
    echo "⚠️  Mix not found. Please install Elixir or manually set SECRET_KEY_BASE"
    echo ""
fi

# Create the PostgreSQL data directory
echo "Creating PostgreSQL data directory..."
if [ -n "$USERPROFILE" ]; then
    # Windows (Git Bash/WSL)
    DATA_DIR="$USERPROFILE/.shroom/postgres-data"
elif [ -n "$HOME" ]; then
    # Linux/Mac
    DATA_DIR="$HOME/.shroom/postgres-data"
else
    echo "❌ Could not determine home directory"
    exit 1
fi

mkdir -p "$DATA_DIR"
echo "✅ Created: $DATA_DIR"
echo ""

echo "📦 Building Docker containers..."
echo "This may take several minutes..."
echo ""

docker-compose -f docker-compose.prod.yml build

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the application:"
echo "  docker-compose -f docker-compose.prod.yml up -d"
echo ""
echo "To view logs:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "To stop the application:"
echo "  docker-compose -f docker-compose.prod.yml down"
echo ""
echo "The app will be available at http://localhost:4000"
echo ""
