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

    test "raises NotFoundError for unknown slugs on mount", %{conn: conn} do
      assert_raise PortfolioWeb.NotFoundError, ~s(project "nope" not found), fn ->
        live(conn, ~p"/projects/nope")
      end
    end

    test "slugs are case sensitive", %{conn: conn} do
      assert_error_sent 404, fn -> get(conn, "/projects/FPInk") end
      assert_error_sent 404, fn -> get(conn, "/projects/fpink%20") end
    end

    test "returns 404 when the slug is missing", %{conn: conn} do
      assert conn |> get("/projects/") |> response(404)
      assert conn |> get("/projects/fpink/extra") |> response(404)
    end

    test "lists every other project but not the current one", %{conn: conn} do
      for project <- Content.projects() do
        {:ok, view, _html} = live(conn, ~p"/projects/#{project.slug}")

        refute has_element?(view, "#other-project-#{project.slug}")

        for other <- Content.projects(), other.slug != project.slug do
          assert has_element?(
                   view,
                   ~s(#other-projects a#other-project-#{other.slug}[href="/projects/#{other.slug}"]),
                   other.name
                 )
        end
      end
    end

    test "renders description, highlights and stack", %{conn: conn} do
      project = Content.get_project("marknotes")
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.slug}")

      assert has_element?(view, "#project-title", project.name)
      assert has_element?(view, "#project", project.tagline)

      for item <- project.highlights ++ project.stack do
        assert has_element?(view, "#project li", item)
      end

      assert view |> element("#project-links") |> render() =~ "btn-primary"
    end

    test "links back to the projects section", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/projects/repentance")

      assert has_element?(view, ~s(a#back-to-projects[href="/#projects"]))
    end

    test "uses the project summary as the meta description", %{conn: conn} do
      project = Content.get_project("privee")

      html = conn |> get(~p"/projects/#{project.slug}") |> html_response(200)
      doc = LazyHTML.from_document(html)

      assert doc |> LazyHTML.query(~s(meta[name="description"])) |> LazyHTML.attribute("content") ==
               [project.summary]

      assert doc |> LazyHTML.query("title") |> LazyHTML.text() =~ project.name
    end

    test "navigates home via the brand link", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/projects/fpink")

      assert {:ok, home, _html} =
               view |> element("#home-link") |> render_click() |> follow_redirect(conn, ~p"/")

      assert has_element?(home, "section#hero")
    end
  end

  describe "home page navigation" do
    test "each project card opens its project page", %{conn: conn} do
      for project <- Content.projects() do
        {:ok, view, _html} = live(conn, ~p"/")

        assert {:ok, project_view, _html} =
                 view
                 |> element("#project-#{project.slug}-read-more")
                 |> render_click()
                 |> follow_redirect(conn, ~p"/projects/#{project.slug}")

        assert has_element?(project_view, "#project-title", project.name)
      end
    end

    test "uses the default meta description and title", %{conn: conn} do
      html = conn |> get(~p"/") |> html_response(200)
      doc = LazyHTML.from_document(html)

      assert [description] =
               doc
               |> LazyHTML.query(~s(meta[name="description"]))
               |> LazyHTML.attribute("content")

      assert description =~ "Software Engineer at Microsoft"
      assert doc |> LazyHTML.query("title") |> LazyHTML.text() =~ "Software Engineer"
    end

    test "shows the about sidebar content", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      for {language, _level} <- Content.profile().languages do
        assert has_element?(view, "#about li", language)
      end

      for e <- Content.education(), do: assert(has_element?(view, "#about", e.school))
      for c <- Content.certifications(), do: assert(has_element?(view, "#about", c.name))

      for {group, _} <- Content.skills(), do: assert(has_element?(view, "#skills h3", group))
    end
  end

  test "GET /health", %{conn: conn} do
    assert conn |> get(~p"/health") |> text_response(200) == "ok"
  end
end
