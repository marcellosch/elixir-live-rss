defmodule RssLiveWeb.FeedLive do
  use RssLiveWeb, :live_view

  def render(assigns) do
    ~H"""
    <table class="min-w-full table-auto">
      <thead class="justify-between">
        <tr class="bg-gray-800">
          <th class="px-16 py-2"> <span class="text-gray-300"> Title </span> </th>
          <th class="px-16 py-2"> <span class="text-gray-300"> Content </span> </th>
          <th class="px-16 py-2"> <span class="text-gray-300"> Date </span> </th>
        </tr>
      </thead>
      <tbody class="bg-gray-200">
        <%= for entry <- @feed do %>
          <tr class="bg-white border-4 border-gray-200">
            <td class="px-16 py-2 flex flex-row items-center"> <a href={entry.url} class="underline text-blue-600 hover:text-blue-800 visited:text-purple-600" target="_blank"><%= entry.title %> </a> </td>
            <td class="px-16 py-2"> <%= entry.content %> </td>
            <td class="px-16 py-2"> <%= entry.updated %> </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(%{"feed_id" => feed_id} = _params, _session, socket) do
    Phoenix.PubSub.subscribe(RssLive.PubSub, feed_id)
    case Registry.lookup(Registry.RssRegistry, feed_id) do
      [{pid, _value}] ->
        feed = RssLive.RssServer.read(pid)
        {:ok, assign(socket, :feed, feed)}
      [] ->
          put_flash(socket, :error, "Let's pretend we have an error.")
          {:ok, assign(socket, :feed, [])}
    end
  end


  def handle_info({:refresh, feed}, socket) do
    {:noreply, assign(socket, :feed, feed)}
  end
end
