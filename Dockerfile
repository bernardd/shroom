# Build stage
FROM elixir:1.19-otp-28-slim AS build

# Install build dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    nodejs \
    npm \
    curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV="prod"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy lib directory first (needed for Tailwind to scan template files)
COPY lib lib

# Copy assets
COPY priv priv
COPY assets assets

# Compile assets (Tailwind will now scan the lib directory)
RUN mix assets.deploy

# Copy rel directory and compile the release
COPY rel rel
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

# Build the release
RUN mix release

# Start a new build stage for a smaller final image
FROM debian:trixie AS app

RUN apt-get update -y && \
    apt-get install -y \
    libstdc++6 \
    openssl \
    libncurses6 \
    locales \
    ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

# Set runner ENV
ENV MIX_ENV="prod"

# Create app user
RUN groupadd -r app && useradd -r -g app app

# Copy built application from build stage
COPY --from=build --chown=app:app /app/_build/${MIX_ENV}/rel/shroom ./

USER app

# Expose port 4000
EXPOSE 4000

# Set default command
CMD ["/app/bin/shroom", "start"]
