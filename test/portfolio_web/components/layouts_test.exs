defmodule PortfolioWeb.LayoutsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias Portfolio.Content
  alias Portfolio.Content.Link
  alias PortfolioWeb.Layouts

  defp query(html, selector), do: html |> LazyHTML.from_fragment() |> LazyHTML.query(selector)

  defp present?(html, selector), do: Enum.count(query(html, selector)) > 0

  defp attribute(html, selector, name), do: html |> query(selector) |> LazyHTML.attribute(name)

  defp text(html, selector), do: html |> query(selector) |> LazyHTML.text() |> String.trim()

  describe "app/1" do
    setup do
      assigns = %{flash: %{"info" => "Welcome!"}}

      html =
        rendered_to_string(~H"""
        <Layouts.app flash={@flash}>
          <p id="inner">Page body</p>
        </Layouts.app>
        """)

      %{html: html}
    end

    test "wraps the inner content in the main landmark", %{html: html} do
      assert text(html, "main#main #inner") == "Page body"
      assert attribute(html, ~s(a[href="#main"]), "class") |> hd() =~ "sr-only"
    end

    test "renders the navbar with section links", %{html: html} do
      assert attribute(html, "#home-link", "href") == ["/"]
      assert text(html, "#home-link") =~ Content.profile().name

      for {label, href} <- [
            {"About", "/#about"},
            {"Projects", "/#projects"},
            {"Experience", "/#experience"},
            {"Skills", "/#skills"}
          ] do
        assert text(html, ~s(#section-nav a[href="#{href}"])) == label
        assert text(html, ~s(#mobile-menu a[href="#{href}"])) == label
      end

      assert attribute(html, "#mobile-menu-toggle", "aria-label") == ["Open menu"]
    end

    test "renders the footer with the current year and social links", %{html: html} do
      assert text(html, "#site-footer") =~ "© #{Date.utc_today().year} #{Content.profile().name}"

      assert attribute(html, ~s(#site-footer a[aria-label="LinkedIn"]), "href") == [
               Content.profile().linkedin
             ]

      assert attribute(html, ~s(#site-footer a[aria-label="GitHub"]), "href") == [
               Content.profile().github
             ]
    end

    test "renders the flash group with the given flash", %{html: html} do
      assert text(html, "#flash-group #flash-info") =~ "Welcome!"
      assert present?(html, "#flash-group #client-error[hidden]")
      assert present?(html, "#flash-group #server-error[hidden]")
    end

    test "includes the theme selector", %{html: html} do
      assert present?(html, "#site-header #theme-selector")
    end
  end

  describe "project_link/1" do
    test "renders primary links as solid external buttons" do
      link = %Link{label: "Try it", url: "https://example.com", kind: :primary}

      html = render_component(&Layouts.project_link/1, link: link, size: "btn-sm")

      assert attribute(html, "a", "href") == ["https://example.com"]
      assert attribute(html, "a", "class") == ["btn btn-sm btn-primary"]
      assert attribute(html, "a", "target") == ["_blank"]
      assert attribute(html, "a", "rel") == ["noopener noreferrer"]
      assert text(html, "a") == "Try it"
    end

    test "renders secondary links as outline buttons" do
      link = %Link{label: "Source", url: "https://github.com/MaxDac"}

      html = render_component(&Layouts.project_link/1, link: link)

      assert attribute(html, "a", "class") == ["btn btn-outline"]
    end
  end

  test "social_link/1 renders an accessible external icon link" do
    html =
      render_component(&Layouts.social_link/1,
        href: "https://github.com/MaxDac",
        label: "GitHub",
        icon: :github
      )

    assert attribute(html, "a", "aria-label") == ["GitHub"]
    assert attribute(html, "a", "class") == ["btn btn-ghost btn-sm btn-square"]
    assert attribute(html, "a", "rel") == ["noopener noreferrer"]
    assert present?(html, "a svg[aria-hidden=true]")
  end

  test "brand_icon/1 renders the GitHub and LinkedIn logos" do
    github = render_component(&Layouts.brand_icon/1, name: :github)
    linkedin = render_component(&Layouts.brand_icon/1, name: :linkedin, class: "size-8")

    assert attribute(github, "svg", "viewBox") == ["0 0 16 16"]
    assert attribute(github, "svg", "class") == ["size-5"]
    assert attribute(linkedin, "svg", "viewBox") == ["0 0 24 24"]
    assert attribute(linkedin, "svg", "class") == ["size-8"]
  end

  test "flash_group/1 renders error flashes and accepts a custom id" do
    html = render_component(&Layouts.flash_group/1, id: "flashes", flash: %{"error" => "Boom"})

    assert text(html, "#flashes #flash-error") =~ "Boom"
    refute present?(html, "#flash-info")
  end

  test "theme_selector/1 renders an option for every theme" do
    html = render_component(&Layouts.theme_selector/1, %{})

    assert attribute(html, "#theme-selector", "phx-update") == ["ignore"]
    assert attribute(html, "#theme-selector-toggle", "aria-haspopup") == ["menu"]

    for {value, name, _icon} <- Content.themes() do
      assert attribute(html, "#theme-option-#{value}", "data-phx-theme") == [value]
      assert attribute(html, "#theme-option-#{value}", "aria-checked") == ["false"]
      assert text(html, "#theme-option-#{value}") == name
    end

    # Built-in themes use an icon, custom themes show a colour swatch.
    assert present?(html, "#theme-option-dark .hero-moon-micro")
    refute present?(html, "#theme-option-dark [data-theme]")
    assert attribute(html, "#theme-option-nord [data-theme]", "data-theme") == ["nord"]
  end
end
