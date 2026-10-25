defmodule Portfolio.ContentTest do
  use ExUnit.Case, async: true

  alias Portfolio.Content
  alias Portfolio.Content.{Link, Project, Role}

  defp valid_url?(url) do
    match?(%URI{scheme: "https", host: host} when is_binary(host) and host != "", URI.parse(url))
  end

  describe "profile/0" do
    test "has the identity fields shown on the site" do
      profile = Content.profile()

      for key <- ~w(name title company location tagline)a do
        assert is_binary(Map.fetch!(profile, key)) and Map.fetch!(profile, key) != ""
      end

      assert [_ | _] = profile.about
      assert Enum.all?(profile.about, &is_binary/1)
    end

    test "lists spoken languages as {language, level} tuples" do
      assert [_ | _] = languages = Content.profile().languages

      for {language, level} <- languages do
        assert is_binary(language) and is_binary(level)
      end
    end

    test "links to GitHub and LinkedIn over https" do
      profile = Content.profile()

      assert profile.github == "https://github.com/MaxDac"
      assert profile.linkedin == "https://www.linkedin.com/in/massimiliano-dacunzo"
    end
  end

  test "highlights/0 returns value/label pairs" do
    assert [_ | _] = highlights = Content.highlights()

    for highlight <- highlights do
      assert %{value: value, label: label} = highlight
      assert is_binary(value) and is_binary(label)
    end
  end

  describe "projects/0" do
    test "includes Tannhauser Gate with its GitHub repository as the primary link" do
      assert %Project{
               name: "Tannhauser Gate",
               links: [
                 %Link{
                   label: "Source on GitHub",
                   url: "https://github.com/MaxDac/tannhauser-gate",
                   kind: :primary
                 }
               ]
             } = Content.get_project("tannhauser-gate")
    end

    test "returns Project structs with unique, URL-safe slugs" do
      projects = Content.projects()

      assert [_ | _] = projects
      assert Enum.all?(projects, &match?(%Project{}, &1))

      slugs = Enum.map(projects, & &1.slug)
      assert slugs == Enum.uniq(slugs)
      assert Enum.all?(slugs, &(&1 =~ ~r/\A[a-z0-9-]+\z/))
    end

    test "every project has the content rendered by the project page" do
      for project <- Content.projects() do
        assert project.name != ""
        assert project.tagline != ""
        assert project.summary != ""
        assert "hero-" <> _ = project.icon
        assert [_ | _] = project.description
        assert [_ | _] = project.highlights
        assert [_ | _] = project.stack
        assert [_ | _] = project.links
      end
    end

    test "project links are https URLs with a valid kind" do
      for project <- Content.projects(), link <- project.links do
        assert %Link{label: label, url: url, kind: kind} = link
        assert label != ""
        assert valid_url?(url), "#{project.slug}: #{inspect(url)} is not an https URL"
        assert kind in [:primary, :secondary]
      end
    end

    test "every project leads with exactly one primary link" do
      for project <- Content.projects() do
        assert [%Link{kind: :primary} | rest] = project.links, project.slug
        refute Enum.any?(rest, &(&1.kind == :primary)), project.slug
      end
    end
  end

  describe "get_project/1" do
    test "finds every project by slug" do
      for project <- Content.projects() do
        assert Content.get_project(project.slug) == project
      end
    end

    test "returns nil for unknown or differently-cased slugs" do
      assert Content.get_project("does-not-exist") == nil
      assert Content.get_project("FPINK") == nil
      assert Content.get_project("") == nil
      assert Content.get_project(nil) == nil
    end
  end

  test "experience/0 returns roles, most recent first" do
    assert [%Role{company: "Microsoft", period: "Apr 2022 – Present"} | _] =
             roles = Content.experience()

    for role <- roles do
      assert role.title != "" and role.company != "" and role.period != ""
      assert [_ | _] = role.bullets
      assert [_ | _] = role.skills
    end
  end

  test "skills/0 returns non-empty named groups" do
    assert [_ | _] = groups = Content.skills()

    for {group, items} <- groups do
      assert is_binary(group)
      assert [_ | _] = items
    end
  end

  test "education/0 and certifications/0 have the fields rendered on the home page" do
    assert [_ | _] = Content.education()
    assert Enum.all?(Content.education(), &match?(%{school: _, degree: _, period: _}, &1))

    assert [_ | _] = Content.certifications()
    assert Enum.all?(Content.certifications(), &match?(%{name: _, issuer: _}, &1))
  end

  describe "themes/0" do
    test "starts with the system theme and has unique values" do
      assert [{"system", "System", _} | _] = themes = Content.themes()

      values = Enum.map(themes, &elem(&1, 0))
      assert values == Enum.uniq(values)
      assert Enum.all?(themes, fn {_, _, icon} -> String.starts_with?(icon, "hero-") end)
    end

    test "matches the themes accepted by the root layout script" do
      root = File.read!("lib/portfolio_web/components/layouts/root.html.heex")
      [_, list] = Regex.run(~r/const THEMES = \[([^\]]+)\]/, root)
      script_themes = Regex.scan(~r/"([^"]+)"/, list, capture: :all_but_first) |> List.flatten()

      selectable = for {value, _, _} <- Content.themes(), value != "system", do: value

      assert Enum.sort(selectable) == Enum.sort(script_themes)
    end

    test "every non-system theme is defined in app.css" do
      css = File.read!("assets/css/app.css")

      for {value, _, _} <- Content.themes(), value != "system" do
        assert css =~ ~s(name: "#{value}";), "theme #{value} is missing from app.css"
      end
    end
  end
end
