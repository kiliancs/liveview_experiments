defmodule CentralizedLiveStateWeb.Router do
  use CentralizedLiveStateWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CentralizedLiveStateWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/counter", CounterLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", CentralizedLiveStateWeb do
  #   pipe_through :api
  # end
end
