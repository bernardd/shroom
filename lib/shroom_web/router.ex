defmodule ShroomWeb.Router do
  use ShroomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShroomWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShroomWeb do
    pipe_through :browser

    live "/", SightingLive.Index, :index
    live "/sightings", SightingLive.Index, :index
    live "/sightings/new", SightingLive.Index, :new
    live "/sightings/:id/edit", SightingLive.Index, :edit
    live "/sightings/:id", SightingLive.Show, :show
    live "/sightings/:id/show/edit", SightingLive.Show, :edit

    get "/photos/:id", PhotoController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShroomWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shroom, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShroomWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
