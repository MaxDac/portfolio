defmodule PortfolioWeb.Router do
  use PortfolioWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PortfolioWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PortfolioWeb do
    get "/health", HealthController, :show
  end

  scope "/", PortfolioWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/projects/:slug", ProjectLive
  end
end
