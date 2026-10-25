defmodule PortfolioWeb.BoilerplateTest do
  use ExUnit.Case, async: true

  test "PortfolioWeb exposes the quoted definitions used by `use PortfolioWeb, ...`" do
    for which <- ~w(router channel controller live_view live_component html verified_routes)a do
      assert Macro.validate(apply(PortfolioWeb, which, [])) == :ok, "#{which} is not quoted"
    end

    assert "assets" in PortfolioWeb.static_paths()
    assert "favicon.svg" in PortfolioWeb.static_paths()
  end

  test "Portfolio.Application.config_change/3 forwards to the endpoint" do
    assert Portfolio.Application.config_change([], [], []) == :ok
  end

  test "PortfolioWeb.Telemetry defines Phoenix and VM metrics" do
    metrics = PortfolioWeb.Telemetry.metrics()
    names = Enum.map(metrics, &Enum.join(&1.name, "."))

    assert "phoenix.endpoint.stop.duration" in names
    assert "vm.memory.total" in names
    assert Enum.all?(metrics, &is_struct/1)
  end
end
