defmodule PortfolioWeb.ProjectLive do
  use PortfolioWeb, :live_view

  alias Portfolio.Content

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    case Content.get_project(slug) do
      nil ->
        raise PortfolioWeb.NotFoundError, "project #{inspect(slug)} not found"

      project ->
        {:ok,
         assign(socket,
           page_title: project.name,
           page_description: project.summary,
           project: project,
           others: Enum.reject(Content.projects(), &(&1.slug == slug))
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <article id="project" class="mx-auto max-w-4xl px-4 py-16 sm:px-6">
        <a id="back-to-projects" href="/#projects" class="link link-hover text-sm opacity-80">
          <span aria-hidden="true">←</span> All projects
        </a>

        <header class="mt-6 flex items-start gap-5">
          <span class="grid size-16 shrink-0 place-items-center rounded-box bg-primary/15 text-primary">
            <.icon name={@project.icon} class="size-8" />
          </span>

          <div>
            <h1 id="project-title" class="text-4xl font-extrabold tracking-tight sm:text-5xl">
              {@project.name}
            </h1>

            <p class="mt-2 text-lg opacity-80">{@project.tagline}</p>
          </div>
        </header>

        <div id="project-links" class="mt-8 flex flex-wrap gap-3">
          <Layouts.project_link :for={link <- @project.links} link={link} />
        </div>

        <div class="mt-10 space-y-4 text-lg leading-relaxed opacity-90">
          <p :for={paragraph <- @project.description}>{paragraph}</p>
        </div>

        <section class="mt-10" aria-labelledby="highlights-title">
          <h2 id="highlights-title" class="text-2xl font-bold">Highlights</h2>

          <ul class="mt-4 space-y-2">
            <li :for={item <- @project.highlights} class="flex gap-3">
              <.icon name="hero-check-circle" class="mt-0.5 size-5 shrink-0 text-primary" />
              <span>{item}</span>
            </li>
          </ul>
        </section>

        <section class="mt-10" aria-labelledby="stack-title">
          <h2 id="stack-title" class="text-2xl font-bold">Built with</h2>

          <ul class="mt-4 flex flex-wrap gap-2">
            <li :for={tech <- @project.stack} class="badge badge-primary badge-outline">{tech}</li>
          </ul>
        </section>

        <nav
          id="other-projects"
          class="mt-16 border-t border-base-300 pt-8"
          aria-label="Other projects"
        >
          <h2 class="text-sm font-semibold uppercase tracking-wider opacity-70">Other projects</h2>

          <ul class="mt-4 grid gap-4 sm:grid-cols-3">
            <li :for={other <- @others}>
              <.link
                id={"other-project-#{other.slug}"}
                navigate={~p"/projects/#{other.slug}"}
                class="block rounded-box border border-base-300 bg-base-200 p-4 transition hover:border-primary"
              >
                <p class="font-semibold">{other.name}</p>

                <p class="text-sm opacity-70">{other.tagline}</p>
              </.link>
            </li>
          </ul>
        </nav>
      </article>
    </Layouts.app>
    """
  end
end
