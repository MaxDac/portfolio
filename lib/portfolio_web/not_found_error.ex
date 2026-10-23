defmodule PortfolioWeb.NotFoundError do
  @moduledoc "Raised when a requested page does not exist; rendered as a 404."
  defexception message: "not found", plug_status: 404
end
