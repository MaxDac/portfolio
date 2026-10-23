defmodule PortfolioWeb.StaticAssetTest do
  use PortfolioWeb.ConnCase, async: true

  test "serves the fingerprinted production favicon", %{conn: conn} do
    digest = Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)
    filename = "favicon-#{digest}.svg"
    path = Application.app_dir(:portfolio, "priv/static/#{filename}")
    favicon = File.read!(Application.app_dir(:portfolio, "priv/static/favicon.svg"))

    File.write!(path, favicon)
    on_exit(fn -> File.rm!(path) end)

    assert conn |> get("/#{filename}") |> response(200) == favicon
  end
end
