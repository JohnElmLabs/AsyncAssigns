defmodule AsyncAssignWeb.UsersLive do
  use AsyncAssignWeb, :live_view

  alias AsyncAssign.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    i'm users live!
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:table_header, "All Users")
      |> assign_async(:admin_user, fn -> {:ok, %{admin_user: Accounts.get_user_by_email("john@johnelmlabs.com")}} end)
      |> assign_async([:john, :tim], fn -> {:ok, %{john: Accounts.get_user_by_email("john@johnelmlabs.com"), tim: Accounts.get_user_by_email("tim@johnelmlabs.com")}} end)
      |> assign_async(:all_users, fn -> {:ok, %{all_users: Accounts.list_users()}} end)}
  end
end
