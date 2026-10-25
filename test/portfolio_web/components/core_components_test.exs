defmodule PortfolioWeb.CoreComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias Phoenix.LiveView.JS
  alias PortfolioWeb.CoreComponents

  defp parse(html), do: LazyHTML.from_fragment(html)

  defp query(html, selector), do: html |> parse() |> LazyHTML.query(selector)

  defp present?(html, selector), do: Enum.count(query(html, selector)) > 0

  defp attribute(html, selector, name), do: html |> query(selector) |> LazyHTML.attribute(name)

  defp text(html, selector), do: html |> query(selector) |> LazyHTML.text() |> String.trim()

  describe "flash/1" do
    test "renders an info flash from the flash map" do
      html =
        render_component(&CoreComponents.flash/1, kind: :info, flash: %{"info" => "Saved!"})

      assert attribute(html, "div[role=alert]", "id") == ["flash-info"]
      assert present?(html, "#flash-info .alert-info")
      assert present?(html, "#flash-info .hero-information-circle")
      assert text(html, "#flash-info") =~ "Saved!"
    end

    test "renders an error flash with a title and a custom id" do
      html =
        render_component(&CoreComponents.flash/1,
          id: "oops",
          kind: :error,
          title: "Uh oh",
          flash: %{"error" => "Broken"}
        )

      assert present?(html, "#oops .alert-error")
      assert present?(html, "#oops .hero-exclamation-circle")
      assert text(html, "#oops p.font-semibold") == "Uh oh"
      assert text(html, "#oops") =~ "Broken"
    end

    test "renders nothing without a message" do
      html = render_component(&CoreComponents.flash/1, kind: :info, flash: %{})

      refute present?(html, "[role=alert]")
    end

    test "prefers the inner block over the flash map" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <CoreComponents.flash kind={:info} flash={%{"info" => "ignored"}}>From slot</CoreComponents.flash>
        """)

      assert text(html, "#flash-info") =~ "From slot"
      refute html =~ "ignored"
    end
  end

  describe "button/1" do
    test "renders a soft button by default" do
      assigns = %{}

      html = rendered_to_string(~H|<CoreComponents.button id="b">Go</CoreComponents.button>|)

      assert attribute(html, "button#b", "class") == ["btn btn-primary btn-soft"]
      assert text(html, "#b") == "Go"
    end

    test "renders the primary variant" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<CoreComponents.button id="b" variant="primary">Go</CoreComponents.button>|
        )

      assert attribute(html, "button#b", "class") == ["btn btn-primary"]
    end

    test "renders a link when given navigation attributes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <CoreComponents.button id="nav" navigate="/projects/fpink">FPInk</CoreComponents.button>
        <CoreComponents.button id="href" href="https://example.com" class="custom">Out</CoreComponents.button>
        <CoreComponents.button id="patch" patch="/?tab=1">Tab</CoreComponents.button>
        """)

      assert attribute(html, "a#nav", "href") == ["/projects/fpink"]
      assert attribute(html, "a#nav", "data-phx-link") == ["redirect"]
      assert attribute(html, "a#href", "class") == ["custom"]
      assert attribute(html, "a#patch", "data-phx-link") == ["patch"]
      refute present?(html, "button")
    end
  end

  describe "input/1" do
    test "renders a text input with label and errors" do
      html =
        render_component(&CoreComponents.input/1,
          id: "name",
          name: "name",
          label: "Name",
          value: "Max",
          errors: ["is too short"]
        )

      assert attribute(html, "input#name", "type") == ["text"]
      assert attribute(html, "input#name", "value") == ["Max"]
      assert attribute(html, "input#name", "class") == ["w-full input input-error"]
      assert text(html, "label span.label") == "Name"
      assert text(html, "p.text-error") == "is too short"
    end

    test "uses custom classes over the defaults" do
      html =
        render_component(&CoreComponents.input/1,
          id: "q",
          name: "q",
          type: "search",
          value: nil,
          class: "mine",
          error_class: "bad",
          errors: ["nope"]
        )

      assert attribute(html, "input#q", "class") == ["mine bad"]
      assert attribute(html, "input#q", "type") == ["search"]
    end

    test "renders a hidden input" do
      html =
        render_component(&CoreComponents.input/1,
          id: "token",
          name: "token",
          type: "hidden",
          value: "abc"
        )

      assert attribute(html, "input#token", "type") == ["hidden"]
      assert attribute(html, "input#token", "value") == ["abc"]
      refute present?(html, "label")
    end

    test "renders a checkbox with its hidden false value" do
      html =
        render_component(&CoreComponents.input/1,
          id: "agree",
          name: "agree",
          type: "checkbox",
          label: "I agree",
          value: "true",
          errors: ["must be accepted"]
        )

      assert attribute(html, ~s(input[type=hidden][name=agree]), "value") == ["false"]
      assert attribute(html, "input#agree", "type") == ["checkbox"]
      assert attribute(html, "input#agree", "checked") == [""]
      assert attribute(html, "input#agree", "class") == ["checkbox checkbox-sm"]
      assert text(html, "label") =~ "I agree"
      assert text(html, "p.text-error") == "must be accepted"
    end

    test "renders an unchecked checkbox" do
      html =
        render_component(&CoreComponents.input/1,
          id: "agree",
          name: "agree",
          type: "checkbox",
          value: "false"
        )

      assert present?(html, "input#agree")
      refute present?(html, "input#agree[checked]")
    end

    test "renders a select with a prompt and the selected option" do
      html =
        render_component(&CoreComponents.input/1,
          id: "theme",
          name: "theme",
          type: "select",
          label: "Theme",
          prompt: "Pick one",
          options: [Light: "light", Dark: "dark"],
          value: "dark",
          errors: ["is invalid"]
        )

      assert attribute(html, "select#theme", "class") == ["w-full select select-error"]
      assert text(html, ~s(option[value=""])) == "Pick one"
      assert attribute(html, "option[selected]", "value") == ["dark"]
      assert text(html, "p.text-error") == "is invalid"
    end

    test "renders a multiple select" do
      html =
        render_component(&CoreComponents.input/1,
          id: "tags",
          name: "tags[]",
          type: "select",
          multiple: true,
          options: ["a", "b"],
          value: ["a", "b"]
        )

      assert attribute(html, "select#tags", "multiple") == [""]
      assert Enum.count(query(html, "option[selected]")) == 2
    end

    test "renders a textarea" do
      html =
        render_component(&CoreComponents.input/1,
          id: "bio",
          name: "bio",
          type: "textarea",
          label: "Bio",
          value: "Hello",
          errors: ["too long"]
        )

      assert attribute(html, "textarea#bio", "class") == ["w-full textarea textarea-error"]
      assert text(html, "textarea#bio") == "Hello"
      assert text(html, "label span.label") == "Bio"
    end

    test "derives name, id, value and errors from a form field" do
      form =
        to_form(%{"email" => "max@example.com"},
          as: :user,
          errors: [email: {"must have the %{char} sign", [char: "@"]}]
        )

      html = render_component(&CoreComponents.input/1, field: form[:email], type: "email")

      assert attribute(html, "input#user_email", "name") == ["user[email]"]
      assert attribute(html, "input#user_email", "value") == ["max@example.com"]
      assert text(html, "p.text-error") == "must have the @ sign"
    end

    test "hides errors of form fields that were not used yet" do
      form = to_form(%{}, as: :user, errors: [email: {"can't be blank", []}])

      html = render_component(&CoreComponents.input/1, field: form[:email])

      refute present?(html, "p.text-error")
    end

    test "appends [] to the name of multiple form fields" do
      form = to_form(%{"tags" => ["a"]}, as: :post)

      html =
        render_component(&CoreComponents.input/1,
          field: form[:tags],
          type: "select",
          multiple: true,
          options: ["a", "b"]
        )

      assert attribute(html, "select#post_tags", "name") == ["post[tags][]"]
    end
  end

  describe "header/1" do
    test "renders title, subtitle and actions" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <CoreComponents.header>
          Title
          <:subtitle>Sub</:subtitle>
          <:actions><a id="act" href="/">Act</a></:actions>
        </CoreComponents.header>
        """)

      assert text(html, "h1") == "Title"
      assert text(html, "p") == "Sub"
      assert present?(html, "header.flex #act")
    end

    test "renders only the title when no slots are given" do
      assigns = %{}

      html = rendered_to_string(~H|<CoreComponents.header>Only</CoreComponents.header>|)

      assert text(html, "h1") == "Only"
      refute present?(html, "p")
      refute present?(html, "header.flex")
    end
  end

  describe "table/1" do
    test "renders rows, columns and actions" do
      assigns = %{rows: [%{id: 1, name: "FPInk"}, %{id: 2, name: "Privee"}]}

      html =
        rendered_to_string(~H"""
        <CoreComponents.table
          id="projects"
          rows={@rows}
          row_id={&"row-#{&1.id}"}
          row_click={&JS.navigate("/projects/#{&1.id}")}
        >
          <:col :let={row} label="Name">{row.name}</:col>
          <:action :let={row}><a id={"edit-#{row.id}"} href="#">Edit</a></:action>
        </CoreComponents.table>
        """)

      assert text(html, "thead th:first-child") == "Name"
      assert text(html, "thead .sr-only") == "Actions"
      assert text(html, "#row-1 td:first-child") == "FPInk"
      assert text(html, "#row-2 td:first-child") == "Privee"
      assert present?(html, "#row-1 #edit-1")
      assert attribute(html, "#row-1 td:first-child", "class") == ["hover:cursor-pointer"]
      refute present?(html, "tbody#projects[phx-update]")
    end

    test "renders without actions or row ids" do
      assigns = %{rows: [%{name: "Plain"}]}

      html =
        rendered_to_string(~H"""
        <CoreComponents.table id="plain" rows={@rows}>
          <:col :let={row}>{row.name}</:col>
        </CoreComponents.table>
        """)

      assert text(html, "tbody td") == "Plain"
      refute present?(html, ".sr-only")
    end
  end

  test "list/1 renders titled items" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <CoreComponents.list>
        <:item title="Name">FPInk</:item>
        <:item title="Stack">Kotlin</:item>
      </CoreComponents.list>
      """)

    assert html |> query("li.list-row") |> Enum.count() == 2
    assert text(html, "li.list-row:first-child .font-bold") == "Name"
    assert text(html, "li.list-row:last-child") =~ "Kotlin"
  end

  test "icon/1 renders a heroicon span with the given classes" do
    html = render_component(&CoreComponents.icon/1, name: "hero-x-mark", class: "size-6")

    assert attribute(html, "span", "class") == ["hero-x-mark size-6"]

    html = render_component(&CoreComponents.icon/1, name: "hero-check")
    assert attribute(html, "span", "class") == ["hero-check size-4"]
  end

  describe "JS commands" do
    test "show/2 and hide/2 target the selector with transitions" do
      assert %JS{ops: [["show", %{to: "#a", time: 300}]]} = CoreComponents.show("#a")
      assert %JS{ops: [["hide", %{to: "#a", time: 200}]]} = CoreComponents.hide("#a")

      assert %JS{ops: [["push", _], ["hide", %{to: "#b"}]]} =
               JS.push("x") |> CoreComponents.hide("#b")

      assert %JS{ops: [["push", _], ["show", %{to: "#b"}]]} =
               JS.push("x") |> CoreComponents.show("#b")
    end
  end

  describe "translate_error/1 and translate_errors/2" do
    test "interpolates options into the message" do
      assert CoreComponents.translate_error(
               {"should be at least %{count} character(s)", [count: 3, validation: :length]}
             ) == "should be at least 3 character(s)"

      assert CoreComponents.translate_error({"is invalid", []}) == "is invalid"
    end

    test "collects the errors for a single field" do
      errors = [
        name: {"can't be blank", [validation: :required]},
        email: {"has invalid format", []},
        name: {"should be %{count} chars", [count: 2]}
      ]

      assert CoreComponents.translate_errors(errors, :name) == [
               "can't be blank",
               "should be 2 chars"
             ]

      assert CoreComponents.translate_errors(errors, :missing) == []
    end
  end
end
