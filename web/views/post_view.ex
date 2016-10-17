defmodule PhoenixChina.PostView do
  use PhoenixChina.Web, :view

  @label_classes %{
    1 => "label-primary",
    2 => "label-success",
    3 => "label-info",
    4 => "label-warning",
    5 => "label-danger",
  }

  def post_label(post) do
    raw ~s(<span class="label #{Map.get(@label_classes, rem(post.label.order + 1, 5), "label-default")}">#{post.label.content}</span>)
  end

  def render("post.json", %{post: post}) do
    %{
      praise_count: post.praise_count
    }
  end
end
