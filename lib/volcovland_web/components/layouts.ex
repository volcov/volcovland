defmodule VolcovlandWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use VolcovlandWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @site_name "Volcovland"
  @site_description "My little world on the internet, where I share about Elixir, " <>
                      "theme parks, and other interests."

  @doc """
  Composes the document title from the `:page_title` assign.

  Pages without one get the bare site name, so the home page doesn't
  read "Volcovland · Volcovland".
  """
  def page_title(nil), do: @site_name
  def page_title(title), do: "#{title} · #{@site_name}"

  @doc """
  SEO and social meta tags for the `<head>`.

  Per-page values come from controller render assigns (`:page_title`,
  `:meta_description`, `:og_type`); anything unset falls back to the
  site-wide defaults. Twitter reads the `og:` tags, so only the card
  type needs spelling out.

  ## Examples

      <.meta_tags
        conn={@conn}
        page_title={assigns[:page_title]}
        description={assigns[:meta_description]}
        og_type={assigns[:og_type]}
      />
  """
  attr :conn, Plug.Conn, required: true
  attr :page_title, :string, default: nil
  attr :description, :string, default: nil
  attr :og_type, :string, default: nil

  def meta_tags(assigns) do
    assigns =
      assigns
      |> assign(:title, assigns.page_title || @site_name)
      |> assign(:description, assigns.description || @site_description)
      |> assign(:og_type, assigns.og_type || "website")

    ~H"""
    <meta name="description" content={@description} />
    <meta property="og:site_name" content="Volcovland" />
    <meta property="og:type" content={@og_type} />
    <meta property="og:title" content={@title} />
    <meta property="og:description" content={@description} />
    <meta property="og:url" content={Phoenix.Controller.current_url(@conn)} />
    <meta property="og:image" content={url(~p"/images/logo-mark-512.png")} />
    <meta name="twitter:card" content="summary" />
    """
  end

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
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
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  The Volcovland mark: an Elixir-style drop with a wooden coaster running through it.

  The badge carries its own dark field, so it needs no light/dark variants.

  `variant` trades detail for size. `:full` keeps the trestle and holds down to about
  28px; `:simple` drops it, for favicons and anything smaller.

  ## Examples

      <Layouts.logo_mark class="h-7 w-7" />
      <Layouts.logo_mark variant={:simple} class="size-4" id="footer-mark" />
  """
  attr :class, :string, default: "h-7 w-7"
  attr :variant, :atom, default: :full, values: [:full, :simple]
  attr :id, :string, default: "vl-mark", doc: "namespaces the internal defs ids"

  def logo_mark(assigns) do
    ~H"""
    <svg class={@class} viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <linearGradient id={"#{@id}-grad"} x1="0.15" y1="0" x2="0.85" y2="1">
          <stop offset="0%" stop-color="#d9ccf8" />
          <stop offset="45%" stop-color="#b89ff1" />
          <stop offset="100%" stop-color="#9878e6" />
        </linearGradient>

        <path
          id={"#{@id}-drop"}
          d="M50 10 C44 28 32 44 27 57 C22 72 32 89 50 89 C68 89 78 72 73 57 C68 44 56 28 50 10 Z"
        />
        <path
          id={"#{@id}-region"}
          d="M6 72 C18 72 26 50 40 50 C54 50 54 68 64 73 C71 77 78 73 94 71 L94 100 L6 100 Z"
        />

        <clipPath id={"#{@id}-clip-drop"}><use href={"##{@id}-drop"} /></clipPath>
        <clipPath id={"#{@id}-clip-region"}><use href={"##{@id}-region"} /></clipPath>
      </defs>

      <rect width="100" height="100" rx="26" fill="#33205b" />
      <use href={"##{@id}-drop"} fill={"url(##{@id}-grad)"} />

      <g clip-path={"url(##{@id}-clip-drop)"}>
        <%!-- deeper band below the track, so the drop reads against the field --%>
        <use href={"##{@id}-region"} fill="#7c4fe0" />

        <%!-- wooden trestle, confined to the band --%>
        <g
          :if={@variant == :full}
          clip-path={"url(##{@id}-clip-region)"}
          stroke="#fff"
          fill="none"
          stroke-linecap="round"
        >
          <g opacity="0.7" stroke-width="1.7">
            <path d="M31 104 L43 44 L55 104 L67 44 L79 104" />
            <path d="M31 44 L43 104 L55 44 L67 104 L79 44" />
          </g>
          <path d="M31 44 V104 M43 44 V104 M55 44 V104 M67 44 V104 M79 44 V104" stroke-width="2.4" />
        </g>

        <%!-- the rail, sitting on the boundary --%>
        <path
          d="M6 72 C18 72 26 50 40 50 C54 50 54 68 64 73 C71 77 78 73 94 71"
          fill="none"
          stroke="#fff"
          stroke-width={if @variant == :full, do: "5.4", else: "6"}
          stroke-linecap="round"
        />

        <%!-- glossy sheen --%>
        <path
          d="M50 10 C44 28 32 44 27 57 C24 66 25 74 29 81 C32 66 39 52 49 39 C56 30 55 20 50 10 Z"
          fill="#fff"
          opacity="0.2"
        />
      </g>
    </svg>
    """
  end

  @doc """
  Site header: the mark and wordmark linking home, plus the theme toggle.

  ## Examples

      <Layouts.site_header />
  """
  def site_header(assigns) do
    ~H"""
    <header class="flex items-center justify-between px-1 sm:px-2">
      <.link
        navigate={~p"/"}
        class="flex items-center gap-2.5 font-semibold tracking-tight text-gray-900 dark:text-white"
      >
        <.logo_mark class="h-7 w-7 flex-shrink-0" /> volcovland
      </.link>

      <.theme_toggle />
    </header>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
