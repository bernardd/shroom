# Shroom

A web-based application for tracking photos and sightings of fungi, built with Elixir, Phoenix, LiveView, and PostGIS.

## Features

- **Record Fungi Sightings**: Upload information about fungi including:
  - Fungi name (if known)
  - Location name
  - GPS coordinates (using PostGIS geometry types)
  - Photo URL
  - Date and time of sighting
  - Additional notes

- **Search Functionality**: Search through sightings by:
  - Fungi name
  - Location name
  - Date ranges

- **View Sightings**: Browse all sightings with photos in a table view
- **Detailed View**: Click on any sighting to see full details

## Prerequisites

- Elixir 1.15 or later
- Docker and Docker Compose (for PostgreSQL with PostGIS)

## Getting Started

1. **Start the PostgreSQL database with PostGIS**:
   ```bash
   docker-compose up -d
   ```

2. **Install dependencies**:
   ```bash
   mix deps.get
   ```

3. **Run database migrations**:
   ```bash
   mix ecto.migrate
   ```

4. **Seed the database with test data** (optional):
   ```bash
   mix run priv/repo/seeds.exs
   ```

   This will populate the database with 12 sample fungi sightings from various Australian locations, including famous species like the Ghost Fungus, Pixie's Parasol, and Amanita muscaria.

5. **Start the Phoenix server**:
   ```bash
   mix phx.server
   ```

   Or run it inside IEx:
   ```bash
   iex -S mix phx.server
   ```

6. **Visit the application**:
   Open [`localhost:4000`](http://localhost:4000) in your browser.

## Database

The application uses PostgreSQL with the PostGIS extension for storing geospatial data. The Docker Compose configuration provides:

- PostgreSQL 14 with PostGIS 3.2
- Port: 5433 (mapped to container's 5432)
- Database: shroom_dev
- Username: postgres
- Password: postgres

## Technology Stack

- **Elixir/Phoenix**: Backend framework
- **LiveView**: Real-time, interactive UI without JavaScript
- **PostGIS**: Geospatial database extension
- **geo_postgis**: Elixir library for PostGIS integration
- **Tailwind CSS**: Styling (via Phoenix default setup)

Ready to run in production? Please [check the deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
