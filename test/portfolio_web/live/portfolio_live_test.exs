defmodule PortfolioWeb.PortfolioLiveTest do
  use PortfolioWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Portfolio.Content

  describe "home page" do
    test "renders every section", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ "Massimiliano D&#39;Acunzo"

      for id <- ~w(hero about projects experience skills contact) do
        assert has_element?(view, "section##{id}")
      end
    end

    test "lists all projects with their live links", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      for project <- Content.projects() do
        assert has_element?(view, "#project-#{project.slug}", project.name)
        assert has_element?(view, ~s(a[href="/projects/#{project.slug}"]))
      end

      assert has_element?(view, ~s(a[href="https://f-droid.org/packages/com.fpink.capture/"]))
      assert has_element?(view, ~s(a[href="https://marknotes.fly.dev"]))
      assert has_element?(view, ~s(a[href="https://bauta.fly.dev"]))
      assert has_element?(view, ~s(a[href="https://github.com/MaxDac/Repentance/releases"]))
    end

    test "shows the whole experience timeline", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      for role <- Content.experience() do
        assert has_element?(view, "#experience h3", role.company)
      end
    end

    test "links to LinkedIn and GitHub", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, ~s(a[href="https://www.linkedin.com/in/massimiliano-dacunzo"]))
      assert has_element?(view, ~s(a[href="https://github.com/MaxDac"]))
    end

    test "renders the theme selector with every theme", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#theme-selector[phx-update=ignore]")

      for {value, name, _icon} <- Content.themes() do
        assert has_element?(view, ~s(#theme-selector [data-phx-theme="#{value}"]), name)
      end
    end
  end

  describe "project page" do
    test "renders details and links", %{conn: conn} do
      for project <- Content.projects() do
        {:ok, view, _html} = live(conn, ~p"/projects/#{project.slug}")

        assert page_title(view) =~ project.name
        assert has_element?(view, "h1", project.name)

        for link <- project.links do
          assert has_element?(view, ~s(a[href="#{link.url}"]))
        end
      end
    end

    test "navigates between projects", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/projects/fpink")

      assert {:ok, _view, html} =
               view
               |> element(~s(nav[aria-label="Other projects"] a[href="/projects/privee"]))
               |> render_click()
               |> follow_redirect(conn)

      assert html =~ "Signal Protocol"
    end

    test "returns 404 for unknown projects", %{conn: conn} do
      assert_error_sent 404, fn -> get(conn, ~p"/projects/does-not-exist") end
    end
  end

  test "GET /health", %{conn: conn} do
    assert conn |> get(~p"/health") |> text_response(200) == "ok"
  end
end
