defmodule CentralizedLiveStateWeb.PageController do
  use CentralizedLiveStateWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
