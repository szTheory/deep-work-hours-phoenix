defmodule DeepWorkHoursWeb.Components.EntryDetailComponent do
  @moduledoc false

  use Phoenix.LiveComponent

  alias DeepWorkHours.Repo
  alias DeepWorkHours.TimeEntry
  alias DeepWorkHoursWeb.PageView

  import Ecto.Query

  def render(assigns) do
    Phoenix.View.render(PageView, "entry_detail_component.html", assigns)
  end

  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    entries =
      from(u in TimeEntry, where: u.id in ^list_of_ids, select: {u.id, u})
      |> Repo.all()
      |> Map.new()

    Enum.map(list_of_assigns, fn assigns ->
      assigns
      |> Map.put(:entry, TimeEntry.changeset(entries[assigns.id]))
      |> Map.put(:hidden, true)
    end)
  end

  def handle_event("toggle", _params, socket) do
    {:noreply,
     socket
     |> assign(:hidden, !socket.assigns.hidden)}
  end

  def handle_event("save", %{"time_entry" => params}, socket) do
    entry = Repo.get!(TimeEntry, socket.assigns.id)

    entry
    |> TimeEntry.changeset(params)
    |> Repo.update()
    |> case do
      {:ok, entry} ->
        {:noreply,
         socket
         |> assign(:hidden, true)
         |> assign(:entry, TimeEntry.changeset(entry))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:hidden, false)
         |> assign(:entry, changeset)}
    end
  end
end
