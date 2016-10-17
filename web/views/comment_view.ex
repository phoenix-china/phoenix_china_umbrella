defmodule PhoenixChina.CommentView do
  use PhoenixChina.Web, :view

  def render("comment.json", %{comment: comment}) do
    %{
      praise_count: comment.praise_count
    }
  end
end
