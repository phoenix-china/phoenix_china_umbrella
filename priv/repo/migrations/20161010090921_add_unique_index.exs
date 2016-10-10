defmodule PhoenixChina.Repo.Migrations.AddUniqueIndex do
  use Ecto.Migration

  def change do
    # 帖子赞
    create unique_index(:post_praises, [:user_id, :post_id])
    # 帖子收藏
    create unique_index(:post_collects, [:user_id, :post_id])
    # 评论赞
    create unique_index(:comment_praises, [:user_id, :comment_id])
    # 用户关注
    create unique_index(:user_follows, [:user_id, :to_user_id])
  end
end
