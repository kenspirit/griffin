defmodule GriffinWeb.Router do
  use GriffinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GriffinWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Griffin.Auth.GuardianPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", GriffinWeb do
    pipe_through [:browser, :auth]

    get "/sign_in_from_live_view", SessionController, :sign_in_from_live_view
    get "/logout", SessionController, :logout

    live "/", PageLive, :index

    live "/signup", AuthLive.Signup, :signup
    live "/login", AuthLive.Login, :login
  end

  scope "/", GriffinWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    live "/spider_configs", SpiderConfigLive.Index, :index
    live "/spider_configs/new", SpiderConfigLive.Index, :new
    live "/spider_configs/:id/edit", SpiderConfigLive.Index, :edit
    live "/spider_configs/:id/show", SpiderConfigLive.Index, :show

    live "/gems", GemLive.Index, :index
    live "/gems/new", GemLive.Index, :new
    live "/gems/:id/edit", GemLive.Index, :edit
    live "/gems/:id/show", GemLive.Index, :show

    live "/gem_types", GemTypeLive.Index, :index
    live "/gem_types/new", GemTypeLive.Index, :new
    live "/gem_types/:id/edit", GemTypeLive.Index, :edit
    live "/gem_types/:id/show", GemTypeLive.Index, :show

    live "/locations", LocationLive.Index, :index
    live "/locations/new", LocationLive.Index, :new
    live "/locations/:id/edit", LocationLive.Index, :edit
    live "/locations/:id/show", LocationLive.Index, :show

    live "/exchange_locations", ExchangeLocationLive.Index, :index
    live "/exchange_locations/new", ExchangeLocationLive.Index, :new
    live "/exchange_locations/:id/edit", ExchangeLocationLive.Index, :edit
    live "/exchange_locations/:id/show", ExchangeLocationLive.Index, :show

    live "/exchange_gems", ExchangeGemLive.Index, :index
    live "/exchange_gems/new", ExchangeGemLive.Index, :new
    live "/exchange_gems/:id/edit", ExchangeGemLive.Index, :edit
    live "/exchange_gems/:id/copy", ExchangeGemLive.Index, :copy
    live "/exchange_gems/:id/show", ExchangeGemLive.Index, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", GriffinWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GriffinWeb.Telemetry
    end
  end
end
