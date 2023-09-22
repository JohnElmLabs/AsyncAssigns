defmodule AsyncAssignWeb.UsersLive do
  use AsyncAssignWeb, :live_view

  alias AsyncAssign.Accounts
  alias Phoenix.LiveView.AsyncResult

  @impl true
  def render(assigns) do
    ~H"""
    <span>Without the async assign helper:</span>
    <div>Admin user:</div>
    <div :if={@admin_user.loading}>
      <span class="animate-pulse">Loading admin ...</span>
    </div>

    <div :if={admin_user = @admin_user.ok? && @admin_user.result}><%= admin_user.email %></div>

    <div class="mt-8">With the async assign helper:</div>
    <.async_result :let={user} assign={@tim}>
      <:loading>
        <span class="animate-pulse">
          Loading Tim...
        </span>
      </:loading>
      <:failed :let={_reason}>Failed to load Tim</:failed>
      <span :if={user}><%= user.email %></span>
    </.async_result>

    <div class="mt-8">If something goes wrong, show an error message with the error slot:</div>
    <.async_result :let={user} assign={@failed_to_load}>
      <:loading><span class="animate-pulse">Loading admin user...</span></:loading>
      <:failed :let={reason}>Failed to load: <%= inspect(reason) %></:failed>
      <%= if user do %>
        <%= user.email %>
      <% else %>
        No admin user yet!
      <% end %>
    </.async_result>

    <div class="mt-8">This start_async tasks fails sometimes:</div>
    <div :if={@low_level.loading}>
      <span class="animate-pulse">
        Loading the sometimes user ...
      </span>
    </div>

    <div :if={low_level = @low_level.ok? && @low_level.result}>
      I succeeded! Email: <%= low_level.email %>
    </div>
    <div :if={@low_level.failed}>We failed to retrieve the user :(</div>

    <h1 class="mt-4 text-2xl font-semibold"><%= @table_header %></h1>

    <span>
      Collections can be iterated over without checking for the existence of the assign with <code>:if</code>!
    </span>

    <div class="container mx-auto mt-10">
      <div class="flex flex-row font-bold">
        <div class="flex-1 p-4 border">ID</div>
        <div class="flex-1 p-4 border">Email</div>
      </div>

      <div :for={user <- @all_users} class="flex flex-row">
        <div class="flex-1 p-4 border"><%= user.id %></div>
        <div class="flex-1 p-4 border"><%= user.email %></div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:low_level, AsyncResult.loading())
     |> start_async(:low_level_task, fn -> Accounts.sometimes_fail!() end)
     |> assign(:table_header, "All Users")
     |> assign_async(:admin_user, fn ->
       {:ok, %{admin_user: Accounts.get_user_by_email("john@johnelmlabs.com")}}
     end)
     |> assign_async(:failed_to_load, fn ->
       Accounts.fail_to_get!("nonexistent@johnelmlabs.com")
     end)
     |> assign_async([:john, :tim], fn ->
       {:ok,
        %{
          john: Accounts.get_user_by_email("john@johnelmlabs.com"),
          tim: Accounts.get_user_by_email("tim@johnelmlabs.com")
        }}
     end)
     |> assign_async(:all_users, fn -> {:ok, %{all_users: Accounts.list_users()}} end)}
  end

  def handle_async(:low_level_task, {:ok, user}, socket) do
    %{low_level: low_level} = socket.assigns
    {:noreply, assign(socket, :low_level, AsyncResult.ok(low_level, user))}
  end

  def handle_async(:low_level_task, {:exit, reason}, socket) do
    # Here we might log if an operation has gone wrong or other side effects
    %{low_level: low_level} = socket.assigns
    {:noreply, assign(socket, :low_level, AsyncResult.failed(low_level, reason))}
  end
end
