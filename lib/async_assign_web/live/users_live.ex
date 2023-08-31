defmodule AsyncAssignWeb.UsersLive do
  use AsyncAssignWeb, :live_view

  alias AsyncAssign.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-2xl font-semibold"><%= @table_header %></h1>

    <span>Without the async assign helper:</span>
    <div> Admin user: </div>
    <div :if={@admin_user.loading}>Loading admin ...</div>
    <div :if={admin_user = @admin_user.ok? && @admin_user.result}><%= admin_user.email %></div>

    <div class="mt-8">With the async assign helper:</div>
    <.async_result :let={user} assign={@admin_user}>
      <:loading>Loading admin user...</:loading>
      <:failed :let={reason}><%= reason %></:failed>
      <%= if user do %>
        <%= user.email %>
      <% else %>
        No admin user yet!
      <% end %>
    </.async_result>

    <div class="mt-8">If something goes wrong:</div>
    <.async_result :let={user} assign={@failed_to_load}>
      <:loading>Loading admin user...</:loading>
      <:failed :let={{:error, reason}}><%= reason %></:failed>
      <%= if user do %>
        <%= user.email %>
      <% else %>
        No admin user yet!
      <% end %>
    </.async_result>

    <div class="container mx-auto mt-10">
      <div class="flex flex-row font-bold">
        <div class="flex-1 p-4 border">ID</div>
        <div class="flex-1 p-4 border">Name</div>
        <div class="flex-1 p-4 border">Email</div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:table_header, "All Users")
      |> assign_async(:admin_user, fn -> {:ok, %{admin_user: Accounts.get_user_by_email("john@johnelmlabs.com")}} end)
      |> assign_async(:failed_to_load, fn -> {:error, "Could not find user with email: nonexistent@johnelmlabs.com!"} end)
      |> assign_async([:john, :tim], fn -> {:ok, %{john: Accounts.get_user_by_email("john@johnelmlabs.com"), tim: Accounts.get_user_by_email("tim@johnelmlabs.com")}} end)
      |> assign_async(:all_users, fn -> {:ok, %{all_users: Accounts.list_users()}} end)}
  end
end
