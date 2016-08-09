defmodule PhoenixChina.NotificationView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.Endpoint


  def render("default_page.json", %{page: page}) do
     %{
       data: render_one(page.entries, __MODULE__, "default_entries.json"),
       pagination: %{
         page_number: page.page_number,
         page_size: page.page_size,
         total_entries: page.total_entries,
         total_pages: page.total_pages,
         has_prev: page.page_number > 1,
         has_next: page.total_pages > page.page_number,
         prev_url: cond do
           page.page_number > 1 ->
             notification_url(Endpoint, :default, page: page.page_number - 1)
           true -> ""
         end,
         next_url: cond do
           page.total_pages > page.page_number ->
             notification_url(Endpoint, :default, page: page.page_number + 1)
           true -> ""
         end,
       }
     }
  end

  def render("default_entries.json", %{notification: entries}) do
    render_many(entries, __MODULE__, "default_entry.json")
  end

  def render("default_entry.json", %{notification: entry}) do
    %{
      html: entry.html
    }
  end
end
