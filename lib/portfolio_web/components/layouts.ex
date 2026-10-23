defmodule PortfolioWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use PortfolioWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders the portfolio layout: sticky navbar with section links and theme
  selector, the page content and the footer.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  slot :inner_block, required: true

  def app(assigns) do
    assigns =
      assigns
      |> assign(:profile, Portfolio.Content.profile())
      |> assign(:nav, [
        {"About", "/#about"},
        {"Projects", "/#projects"},
        {"Experience", "/#experience"},
        {"Skills", "/#skills"}
      ])

    ~H"""
    <a
      href="#main"
      class="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-50 btn btn-sm btn-primary"
    >
      Skip to content
    </a>
    <header class="sticky top-0 z-40 border-b border-base-300 bg-base-100/85 backdrop-blur">
      <nav class="navbar mx-auto max-w-6xl px-4 sm:px-6" aria-label="Main">
        <div class="flex-1">
          <.link navigate={~p"/"} class="flex items-center gap-2 font-bold tracking-tight">
            <span class="grid size-9 place-items-center rounded-box bg-primary text-primary-content text-sm">
              MD
            </span>
            <span class="hidden sm:inline">{@profile.name}</span>
          </.link>
        </div>
        <ul class="hidden md:flex items-center gap-1">
          <li :for={{label, href} <- @nav}>
            <a href={href} class="btn btn-ghost btn-sm">{label}</a>
          </li>
        </ul>
        <div class="flex items-center gap-1">
          <.theme_selector />
          <div class="dropdown dropdown-end md:hidden">
            <div tabindex="0" role="button" class="btn btn-ghost btn-sm" aria-label="Open menu">
              <.icon name="hero-bars-3" class="size-5" />
            </div>
            <ul
              tabindex="0"
              class="dropdown-content menu z-50 mt-2 w-48 rounded-box border border-base-300 bg-base-200 p-2 shadow-lg"
            >
              <li :for={{label, href} <- @nav}><a href={href}>{label}</a></li>
            </ul>
          </div>
        </div>
      </nav>
    </header>

    <main id="main">
      {render_slot(@inner_block)}
    </main>

    <footer class="border-t border-base-300 bg-base-200">
      <div class="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 px-4 py-8 sm:flex-row sm:px-6">
        <p class="text-sm opacity-70">
          © {Date.utc_today().year} {@profile.name} · Built with Elixir, Phoenix LiveView and Fly.io
        </p>
        <div class="flex items-center gap-2">
          <.social_link href={@profile.linkedin} label="LinkedIn" icon={:linkedin} />
          <.social_link href={@profile.github} label="GitHub" icon={:github} />
        </div>
      </div>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  attr :link, Portfolio.Content.Link, required: true
  attr :size, :string, default: nil

  def project_link(assigns) do
    ~H"""
    <a
      href={@link.url}
      class={["btn", @size, if(@link.kind == :primary, do: "btn-primary", else: "btn-outline")]}
      target="_blank"
      rel="noopener noreferrer"
    >
      {@link.label}
      <.icon name="hero-arrow-top-right-on-square-micro" class="size-4" />
    </a>
    """
  end

  attr :href, :string, required: true
  attr :label, :string, required: true
  attr :icon, :atom, values: [:github, :linkedin], required: true
  attr :class, :string, default: "btn btn-ghost btn-sm btn-square"

  def social_link(assigns) do
    ~H"""
    <a href={@href} class={@class} target="_blank" rel="noopener noreferrer" aria-label={@label}>
      <.brand_icon name={@icon} class="size-5" />
    </a>
    """
  end

  attr :name, :atom, values: [:github, :linkedin], required: true
  attr :class, :string, default: "size-5"

  def brand_icon(%{name: :github} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
      <path d="M8 0c4.42 0 8 3.58 8 8a8.013 8.013 0 0 1-5.45 7.59c-.4.08-.55-.17-.55-.38 0-.27.01-1.13.01-2.2 0-.75-.25-1.23-.54-1.48 1.78-.2 3.65-.88 3.65-3.95 0-.88-.31-1.59-.82-2.15.08-.2.36-1.02-.08-2.12 0 0-.67-.22-2.2.82-.64-.18-1.32-.27-2-.27-.68 0-1.36.09-2 .27-1.53-1.03-2.2-.82-2.2-.82-.44 1.1-.16 1.92-.08 2.12-.51.56-.82 1.28-.82 2.15 0 3.06 1.86 3.75 3.64 3.95-.23.2-.44.55-.51 1.07-.46.21-1.61.55-2.33-.66-.15-.24-.6-.83-1.23-.82-.67.01-.27.38.01.53.34.19.73.9.82 1.13.16.45.68 1.31 2.69.94 0 .67.01 1.3.01 1.49 0 .21-.15.45-.55.38A7.995 7.995 0 0 1 0 8c0-4.42 3.58-8 8-8Z" />
    </svg>
    """
  end

  def brand_icon(%{name: :linkedin} = assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
    </svg>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Theme selector listing the themes defined in app.css.

  The inline script in root.html.heex applies the saved theme before the page
  renders, persists the choice in localStorage and marks the active option.
  The container is ignored by LiveView patches so those client-side attributes
  survive re-renders.
  """
  def theme_selector(assigns) do
    assigns = assign(assigns, :themes, Portfolio.Content.themes())

    ~H"""
    <div id="theme-selector" class="dropdown dropdown-end" phx-update="ignore">
      <div
        tabindex="0"
        role="button"
        class="btn btn-ghost btn-sm gap-1"
        aria-label="Choose colour theme"
        aria-haspopup="menu"
      >
        <.icon name="hero-swatch" class="size-5" />
        <span class="hidden sm:inline" data-theme-label>Theme</span>
        <.icon name="hero-chevron-down-micro" class="size-4 opacity-60" />
      </div>
      <ul
        tabindex="0"
        role="menu"
        aria-label="Colour themes"
        class="dropdown-content menu z-50 mt-2 w-48 rounded-box border border-base-300 bg-base-200 p-2 shadow-lg"
      >
        <li :for={{value, name, icon} <- @themes} role="none">
          <button
            type="button"
            role="menuitemradio"
            aria-checked="false"
            class="group flex w-full items-center gap-2"
            data-phx-theme={value}
            data-theme-name={name}
            phx-click={JS.dispatch("phx:set-theme")}
          >
            <span
              :if={value not in ["system", "light", "dark"]}
              data-theme={value}
              class="flex gap-0.5 rounded-sm bg-base-100 p-1"
              aria-hidden="true"
            >
              <span class="size-2 rounded-full bg-primary"></span>
              <span class="size-2 rounded-full bg-secondary"></span>
              <span class="size-2 rounded-full bg-accent"></span>
            </span>
            <.icon :if={value in ["system", "light", "dark"]} name={icon} class="size-4 mx-1" />
            <span class="flex-1 text-left">{name}</span>
            <.icon name="hero-check-micro" class="size-4 invisible group-aria-checked:visible" />
          </button>
        </li>
      </ul>
    </div>
    """
  end
end
