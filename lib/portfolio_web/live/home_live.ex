defmodule PortfolioWeb.HomeLive do
  use PortfolioWeb, :live_view

  alias Portfolio.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Software Engineer",
       profile: Content.profile(),
       highlights: Content.highlights(),
       projects: Content.projects(),
       experience: Content.experience(),
       skills: Content.skills(),
       education: Content.education(),
       certifications: Content.certifications()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <%!-- Hero --%>
      <section id="hero" class="relative overflow-hidden">
        <div
          class="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,var(--color-primary)_0%,transparent_55%)] opacity-15"
          aria-hidden="true"
        />
        <div class="relative mx-auto max-w-6xl px-4 py-20 sm:px-6 sm:py-28">
          <p class="font-mono text-sm text-primary">Hello, I'm</p>

          <h1 class="mt-2 text-4xl font-extrabold tracking-tight sm:text-6xl">{@profile.name}</h1>

          <p class="mt-3 text-xl font-semibold opacity-80 sm:text-2xl">
            {@profile.title} at {@profile.company}
            <span class="opacity-60">· {@profile.location}</span>
          </p>

          <p class="mt-6 max-w-2xl text-lg opacity-80">{@profile.tagline}</p>

          <div class="mt-8 flex flex-wrap gap-3">
            <a id="hero-cta" href="#projects" class="btn btn-primary">
              See my projects <.icon name="hero-arrow-down" class="size-4" />
            </a>

            <a
              href={@profile.linkedin}
              class="btn btn-outline"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Layouts.brand_icon name={:linkedin} class="size-4" /> LinkedIn
            </a>

            <a
              href={@profile.github}
              class="btn btn-outline"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Layouts.brand_icon name={:github} class="size-4" /> GitHub
            </a>
          </div>

          <dl class="mt-14 grid grid-cols-2 gap-4 lg:grid-cols-4">
            <div
              :for={h <- @highlights}
              class="flex flex-col rounded-box border border-base-300 bg-base-200/60 p-5"
            >
              <dt class="text-sm opacity-70">{h.label}</dt>

              <dd class="order-first text-3xl font-bold text-primary">{h.value}</dd>
            </div>
          </dl>
        </div>
      </section>
      <%!-- About --%>
      <.section id="about" title="About me" eyebrow="01">
        <div class="grid gap-10 lg:grid-cols-3">
          <div class="space-y-4 text-lg leading-relaxed opacity-90 lg:col-span-2">
            <p :for={paragraph <- @profile.about}>{paragraph}</p>
          </div>

          <aside class="space-y-6">
            <div class="rounded-box border border-base-300 bg-base-200 p-5">
              <h3 class="font-semibold">Languages</h3>

              <ul class="mt-3 space-y-2">
                <li :for={{lang, level} <- @profile.languages} class="flex justify-between gap-4">
                  <span>{lang}</span> <span class="text-sm opacity-70">{level}</span>
                </li>
              </ul>
            </div>

            <div class="rounded-box border border-base-300 bg-base-200 p-5">
              <h3 class="font-semibold">Education</h3>

              <ul class="mt-3 space-y-2">
                <li :for={e <- @education}>
                  <p class="font-medium">{e.school}</p>

                  <p class="text-sm opacity-70">{e.degree} · {e.period}</p>
                </li>
              </ul>

              <h3 class="mt-5 font-semibold">Certifications</h3>

              <ul class="mt-3 space-y-2">
                <li :for={c <- @certifications}>
                  <p class="font-medium">{c.name}</p>

                  <p class="text-sm opacity-70">{c.issuer}</p>
                </li>
              </ul>
            </div>
          </aside>
        </div>
      </.section>
      <%!-- Projects --%>
      <.section id="projects" title="Projects" eyebrow="02" class="bg-base-200">
        <p class="-mt-4 mb-10 max-w-2xl opacity-80">
          Open-source apps I design, build and ship in my own time.
        </p>

        <div class="grid gap-6 md:grid-cols-2">
          <article
            :for={project <- @projects}
            id={"project-#{project.slug}"}
            class="card border border-base-300 bg-base-100 shadow-sm transition hover:-translate-y-0.5 hover:shadow-lg"
          >
            <div class="card-body">
              <div class="flex items-start gap-4">
                <span class="grid size-12 shrink-0 place-items-center rounded-box bg-primary/15 text-primary">
                  <.icon name={project.icon} class="size-6" />
                </span>

                <div>
                  <h3 class="card-title text-2xl">
                    <.link
                      id={"project-#{project.slug}-title-link"}
                      navigate={~p"/projects/#{project.slug}"}
                      class="hover:underline"
                    >
                      {project.name}
                    </.link>
                  </h3>

                  <p class="text-sm font-medium opacity-70">{project.tagline}</p>
                </div>
              </div>

              <p class="mt-2 opacity-90">{project.summary}</p>

              <ul class="mt-2 flex flex-wrap gap-2" aria-label="Technologies">
                <li :for={tech <- project.stack} class="badge badge-outline badge-sm">{tech}</li>
              </ul>

              <div class="card-actions mt-4 flex-wrap items-center">
                <.link
                  id={"project-#{project.slug}-read-more"}
                  navigate={~p"/projects/#{project.slug}"}
                  class="link link-hover mr-auto text-sm"
                >
                  Read more <span aria-hidden="true">→</span>
                </.link>

                <Layouts.project_link
                  :for={link <- Enum.take(project.links, 2)}
                  link={link}
                  size="btn-sm"
                />
              </div>
            </div>
          </article>
        </div>
      </.section>
      <%!-- Experience --%>
      <.section id="experience" title="Experience" eyebrow="03">
        <ol class="relative space-y-10 border-l-2 border-base-300 pl-8">
          <li :for={role <- @experience} class="relative">
            <span
              class="absolute -left-[2.6rem] top-1.5 size-4 rounded-full border-4 border-base-100 bg-primary"
              aria-hidden="true"
            />
            <div class="flex flex-wrap items-baseline justify-between gap-x-4">
              <h3 class="text-xl font-bold">
                {role.title} <span class="text-primary">· {role.company}</span>
              </h3>

              <p class="font-mono text-sm opacity-70">{role.period}</p>
            </div>

            <p :if={role.location} class="text-sm opacity-70">{role.location}</p>

            <p :if={role.summary} class="mt-3 opacity-90">{role.summary}</p>

            <ul class="mt-3 list-disc space-y-1.5 pl-5 opacity-90 marker:text-primary">
              <li :for={bullet <- role.bullets}>{bullet}</li>
            </ul>

            <ul class="mt-3 flex flex-wrap gap-2" aria-label="Skills">
              <li :for={skill <- role.skills} class="badge badge-ghost badge-sm">{skill}</li>
            </ul>
          </li>
        </ol>
      </.section>
      <%!-- Skills --%>
      <.section id="skills" title="Skills" eyebrow="04" class="bg-base-200">
        <div class="grid gap-6 md:grid-cols-3">
          <div
            :for={{group, items} <- @skills}
            class="rounded-box border border-base-300 bg-base-100 p-6"
          >
            <h3 class="font-semibold">{group}</h3>

            <ul class="mt-4 flex flex-wrap gap-2">
              <li :for={item <- items} class="badge badge-primary badge-outline">{item}</li>
            </ul>
          </div>
        </div>
      </.section>
      <%!-- Contact --%>
      <.section id="contact" title="Get in touch" eyebrow="05">
        <div class="rounded-box border border-base-300 bg-base-200 p-8 text-center sm:p-12">
          <p class="mx-auto max-w-xl text-lg opacity-90">
            Interested in working together, or want to chat about distributed systems, Elixir or
            any of my projects? Reach out on LinkedIn or find me on GitHub.
          </p>

          <div class="mt-6 flex flex-wrap justify-center gap-3">
            <a
              href={@profile.linkedin}
              class="btn btn-primary"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Layouts.brand_icon name={:linkedin} class="size-4" /> Connect on LinkedIn
            </a>

            <a
              href={@profile.github}
              class="btn btn-outline"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Layouts.brand_icon name={:github} class="size-4" /> Follow on GitHub
            </a>
          </div>
        </div>
      </.section>
    </Layouts.app>
    """
  end

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :eyebrow, :string, required: true
  attr :class, :string, default: nil
  slot :inner_block, required: true

  defp section(assigns) do
    ~H"""
    <section id={@id} class={["py-20", @class]} aria-labelledby={"#{@id}-title"}>
      <div class="mx-auto max-w-6xl px-4 sm:px-6">
        <h2
          id={"#{@id}-title"}
          class="mb-10 flex items-center gap-3 text-3xl font-bold tracking-tight"
        >
          <span class="font-mono text-base text-primary">{@eyebrow}.</span> {@title}
          <span class="h-px flex-1 bg-base-300" aria-hidden="true" />
        </h2>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end
end
