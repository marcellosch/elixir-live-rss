defmodule RssLiveWeb.LiveHTML do
  use RssLiveWeb, :html
  import Phoenix.HTML.Form
  alias RssLiveWeb.Router.Helpers, as: Routes

  embed_templates "live_html/*"
end
