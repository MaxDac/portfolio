defmodule Portfolio.Content do
  @moduledoc """
  Static portfolio content: profile, projects, experience, skills and education.

  Everything shown on the site lives here, so updating the portfolio only means
  editing this module.
  """

  defmodule Link do
    @moduledoc false
    @enforce_keys [:label, :url]
    defstruct [:label, :url, kind: :secondary]
  end

  defmodule Project do
    @moduledoc false
    @enforce_keys [:slug, :name, :tagline, :summary]
    defstruct [
      :slug,
      :name,
      :tagline,
      :summary,
      :icon,
      description: [],
      highlights: [],
      stack: [],
      links: []
    ]
  end

  defmodule Role do
    @moduledoc false
    @enforce_keys [:title, :company, :period]
    defstruct [:title, :company, :period, :location, summary: nil, bullets: [], skills: []]
  end

  alias __MODULE__.{Link, Project, Role}

  @github "https://github.com/MaxDac"
  @linkedin "https://www.linkedin.com/in/massimiliano-dacunzo"

  def profile do
    %{
      name: "Massimiliano D'Acunzo",
      title: "Software Engineer",
      company: "Microsoft",
      location: "Dublin, Ireland",
      tagline:
        "I design, build and modernise cloud-scale distributed systems, and in my spare time I ship open-source apps.",
      about: [
        "Software Engineer with 15 years of experience designing, building, and modernising cloud-scale distributed systems across Microsoft 365, enterprise software, telecommunications, utilities, and aerospace domains.",
        "Currently at Microsoft, developing and modernising Microsoft 365 commerce services using C#, .NET, Azure, and Service Fabric, with a strong focus on reliability, operational excellence, and platform modernisation. I contributed to significant cost savings through the migration of Microsoft Editor backend services to .NET 10 and Service Fabric.",
        "Strong expertise in distributed systems, microservices, cloud-native architectures, CI/CD, Service Reliability Engineering (SRE), and software architecture. Outside work I build open-source apps with Elixir and Phoenix, Kotlin, Rust and Godot."
      ],
      languages: [
        {"Italian", "Native"},
        {"Portuguese", "Fluent"},
        {"English", "Full professional"}
      ],
      github: @github,
      linkedin: @linkedin
    }
  end

  def highlights do
    [
      %{value: "15+", label: "years building software"},
      %{value: "~2T", label: "monthly requests on services I modernised"},
      %{value: "99.99%", label: "reliability on Microsoft Editor services"},
      %{value: "$9.4M", label: "annual infrastructure savings from the migration programme"}
    ]
  end

  def projects do
    [
      %Project{
        slug: "fpink",
        name: "FPInk",
        icon: "hero-pencil",
        tagline: "Handwritten fountain-pen notes, recognised offline",
        summary:
          "An Android app that turns photos of handwritten fountain-pen notes into searchable text while preserving the detected ink colours. 100% offline and FOSS, available on F-Droid.",
        description: [
          "FPInk captures handwritten notes with the camera and recognises the text entirely on the device: no network, no telemetry. It ships two bundled recognition strategies, Cursive for handwriting (the default) and Printed for printed text, and you can pick one per photo.",
          "After recognition, a review screen lets you correct every generated paragraph in place before saving. The detected ink colour of each note is kept, so your notes look like the page they came from."
        ],
        highlights: [
          "On-device recognition with ONNX Runtime (PaddleOCR and Kraken models)",
          "Ink colour detection and preservation",
          "Review and correction flow, multi-select and bulk delete",
          "Reproducible, upstream-signed builds published on F-Droid and GitHub Releases",
          "Licensed GPL-3.0"
        ],
        stack: ["Kotlin", "Android", "ONNX Runtime", "OCR"],
        links: [
          %Link{
            label: "Get it on F-Droid",
            url: "https://f-droid.org/packages/com.fpink.capture/",
            kind: :primary
          },
          %Link{label: "Source on GitHub", url: "#{@github}/fpink"},
          %Link{label: "Latest APK release", url: "#{@github}/fpink/releases/latest"}
        ]
      },
      %Project{
        slug: "marknotes",
        name: "MarkNotes",
        icon: "hero-document-text",
        tagline: "Offline-first markdown notes on Android, desktop and the web",
        summary:
          "A family of markdown notes apps with folders, note links and sync to Proton Drive, Dropbox and OneDrive, sharing a sync core written in Rust.",
        description: [
          "MarkNotes keeps every note as a plain .md file in a folder tree. It has a markdown editor with live preview, a formatting toolbar, smart list continuation, and stable note links: type @ to search and link any other note.",
          "The same note format and sync layout are shared by the Android app (Kotlin), the desktop app (Electron) and the web app (Phoenix LiveView with IndexedDB, so note content never leaves the browser). A shared Rust core implements the sync planner, three-way merge and manifest, exposed through UniFFI and WASM bindings, and a common spec with conformance fixtures keeps the apps in parity."
        ],
        highlights: [
          "Android, Electron desktop and Phoenix LiveView web clients",
          "Sync to Proton Drive (unofficial), Dropbox and OneDrive",
          "Rust sync core with three-way merge, compiled to UniFFI and WASM",
          "Shared format spec, feature-parity matrix and conformance fixtures"
        ],
        stack: ["Elixir", "Phoenix LiveView", "Kotlin", "Electron", "Rust", "WASM"],
        links: [
          %Link{label: "Open MarkNotes Web", url: "https://marknotes.fly.dev", kind: :primary},
          %Link{label: "Android app", url: "#{@github}/MarkNotes/releases"},
          %Link{label: "Desktop app", url: "#{@github}/marknotes-electron"},
          %Link{label: "Web app source", url: "#{@github}/marknotes-web"},
          %Link{label: "Sync core (Rust)", url: "#{@github}/marknotes-sync"},
          %Link{label: "Spec", url: "#{@github}/marknotes-spec"}
        ]
      },
      %Project{
        slug: "repentance",
        name: "Repentance",
        icon: "hero-puzzle-piece",
        tagline: "A noir point-and-click adventure: Chicago, 1927",
        summary:
          "A collaborative, non-profit pixel-art adventure of Christian inspiration, in the spirit of Monkey Island 2, built with Godot and C#.",
        description: [
          "Today, Daniel is clearing out the attic of the old house he just bought when he finds the journal of Micah Jones, a private eye. In 1927, Teddy Harrington III, heir to Harrington Steel, hired Micah to find his missing wife, Eleanor.",
          "Repentance is a 480×270 pixel-art game with a right-click verb wheel. It is free and built together by its contributors: a story about sin, grace and repentance, offered freely, and licensed so that nobody may profit from it."
        ],
        highlights: [
          "Built with Godot 4 (.NET) and C#",
          "Branching dialogue written in Ink (via GodotInk)",
          "Open to contributions of code, art, dialogue, tests and docs",
          "Non-commercial and free to play"
        ],
        stack: ["Godot", "C#", ".NET", "Ink"],
        links: [
          %Link{label: "Download", url: "#{@github}/Repentance/releases", kind: :primary},
          %Link{label: "Source on GitHub", url: "#{@github}/Repentance"}
        ]
      },
      %Project{
        slug: "privee",
        name: "Privee",
        icon: "hero-lock-closed",
        tagline: "End-to-end encrypted chat you can host yourself",
        summary:
          "A Phoenix LiveView chat with Signal Protocol end-to-end encryption, a native Android client and one-click self-hosting on Fly.io.",
        description: [
          "Privee is a Phoenix LiveView umbrella application whose chats are end-to-end encrypted with the Signal Protocol, across the web client and a native Android app. Its encryption design and trade-offs are documented and independently audited.",
          "Anyone can run their own server: fork PriveeDeploy, add Fly.io keys and run the Deploy workflow. Clients just ask for the server address, so nothing in the apps has to change. The UI is available in English, Italian, Portuguese, Spanish and French."
        ],
        highlights: [
          "Signal Protocol end-to-end encryption, with an independent E2EE audit",
          "Phoenix LiveView umbrella app and native Android client",
          "Self-hosting on Fly.io through a fork-and-deploy workflow",
          "Five UI languages"
        ],
        stack: ["Elixir", "Phoenix LiveView", "Signal Protocol", "Android", "Fly.io"],
        links: [
          %Link{label: "Try Privee", url: "https://bauta.fly.dev", kind: :primary},
          %Link{label: "Source on GitHub", url: "#{@github}/Privee"},
          %Link{label: "Android app", url: "#{@github}/PriveeApp/releases/latest"},
          %Link{label: "Deploy your own", url: "#{@github}/PriveeDeploy"}
        ]
      }
    ]
  end

  def get_project(slug), do: Enum.find(projects(), &(&1.slug == slug))

  def experience do
    [
      %Role{
        title: "Software Engineer",
        company: "Microsoft",
        period: "Apr 2022 – Present",
        location: "Dublin, Ireland · Hybrid",
        bullets: [
          "Modernised Microsoft Editor services handling approximately 2 trillion monthly requests with 99.99% reliability, contributing to a .NET and Service Fabric migration programme delivering $9.4M in annual infrastructure savings.",
          "Delivered Service Fabric deployment, networking, testing, and observability solutions across public, sovereign, and restricted clouds, including safer service routing through Reverse Proxy.",
          "Contributed to Microsoft 365 Copilot experiences spanning Windows integration, cloud services, telemetry, security, and controlled feature rollout.",
          "Applied Service Reliability Engineering practices to improve operational quality, production stability, and service resilience.",
          "Adopted agentic development with GitHub Copilot CLI and coding agents using frontier AI models."
        ],
        skills: ["C#", ".NET", "Azure", "Service Fabric", "CI/CD", "SRE"]
      },
      %Role{
        title: "Microsoft .NET Consultant",
        company: "Version 1",
        period: "Nov 2020 – Mar 2022",
        location: "Dublin, Ireland · Remote",
        summary:
          "Developed and maintained web applications for Dubai Aerospace Enterprise (DAE), a leading aircraft leasing company.",
        bullets: [
          "Built scalable solutions using .NET Framework, .NET Core, and Angular to manage aircraft fleet operations.",
          "Designed and implemented features to automate aircraft cost estimations, improving efficiency and accuracy.",
          "Collaborated with cross-functional teams to deliver high-quality, user-friendly applications aligned with business needs."
        ],
        skills: [".NET Core", "C#", "Angular"]
      },
      %Role{
        title: "Senior Software Developer / Solution Architect",
        company: "Engineering do Brasil",
        period: "Aug 2017 – Nov 2020",
        location: "São Paulo, Brazil",
        summary:
          "Technical expertise and solution design for a global leader in digital transformation, from client requirements to delivery, while mentoring junior developers.",
        bullets: [
          "Conceptualised, developed and released two major products for the commercial area of the largest water supplier in South America.",
          "Redesigned the back-end architecture of the company application system, reducing deployment time.",
          "Translated client and technical requirements into solutions: process analysis, design documents and support for business objectives.",
          "Built back-office processing and client-facing user interface applications."
        ],
        skills: ["Distributed Systems", "Software Architecture", "Mentoring"]
      },
      %Role{
        title: "Software Developer",
        company: "Adam Phones Limited",
        period: "Feb 2016 – Jun 2017",
        location: "London, United Kingdom",
        bullets: [
          "Developed, tested and delivered beta iOS and Android versions of a telecom app that let customers check tariffs, usage, bundles and invoices.",
          "Built microservices orchestrated by RabbitMQ brokers and helped the back-end team design the microservices architecture."
        ],
        skills: ["Microservices", "RabbitMQ", "Mobile"]
      },
      %Role{
        title: "Analyst Programmer",
        company: "Engineering Ingegneria Informatica",
        period: "Mar 2011 – Jan 2016",
        location: "Italy · São Paulo, Brazil",
        summary:
          "Full-stack developer in the energy and utilities sector, starting as an intern in Giulianova.",
        bullets: [
          "Extended the application across front end, back end and Oracle database, delivering client extensions and bug fixes with solution experts and analysts.",
          "Led a five-developer spin-off team in São Paulo (Mar–Jul 2015), tutoring them on programming and the NET@SIU product framework.",
          "Directed the technology stack and mentored the Brazilian division's junior developers on frameworks and architecture."
        ],
        skills: ["Full stack", "Oracle", "Mentoring"]
      }
    ]
  end

  def skills do
    [
      {"Languages", ["C#", "Elixir", "Kotlin", "Rust", "TypeScript", "F#", "Scala"]},
      {"Platforms & cloud",
       [".NET", "Azure", "Service Fabric", "Phoenix LiveView", "Android", "Fly.io"]},
      {"Practices",
       [
         "Distributed systems",
         "Microservices",
         "Cloud-native architecture",
         "CI/CD",
         "Service Reliability Engineering",
         "Agentic development"
       ]}
    ]
  end

  def education do
    [
      %{
        school: "Politecnico di Milano",
        degree: "Master's Degree, Physical Engineering",
        period: "2003 – 2010"
      }
    ]
  end

  def certifications do
    [%{name: "Microsoft Global Hackathon 2022", issuer: "Microsoft"}]
  end

  def themes do
    [
      {"system", "System", "hero-computer-desktop-micro"},
      {"light", "Light", "hero-sun-micro"},
      {"dark", "Dark", "hero-moon-micro"},
      {"gruvbox", "Gruvbox", "hero-swatch-micro"},
      {"nord", "Nord", "hero-swatch-micro"},
      {"solarized", "Solarized", "hero-swatch-micro"},
      {"dracula", "Dracula", "hero-swatch-micro"}
    ]
  end
end
