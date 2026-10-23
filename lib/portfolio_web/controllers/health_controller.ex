defmodule PortfolioWeb.HealthController do
  use PortfolioWeb, :controller

  def show(conn, _params), do: text(conn, "ok")
end
