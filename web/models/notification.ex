defmodule PhoenixChina.Notification do
  use PhoenixChina.Web, :model

  schema "notificatons" do
    field :action, :string
    field :data_id, :integer
    field :html, :string
    field :json, :map
    belongs_to :user, PhoenixChina.User
    belongs_to :operator, PhoenixChina.Operator

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:action, :data_id, :html, :json])
    |> validate_required([:action, :data_id, :html, :json])
  end
end
