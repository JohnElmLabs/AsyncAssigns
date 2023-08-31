defmodule AsyncAssignWeb.UsersLive do
  use AsyncAssignWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    i'm users live!
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
