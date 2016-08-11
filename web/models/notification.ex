defmodule PhoenixChina.Notification do
  use PhoenixChina.Web, :model

  schema "notificatons" do
    field :action, :string
    field :data_id, :integer
    field :html, :string
    belongs_to :user, PhoenixChina.User
    belongs_to :operator, PhoenixChina.Operator

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:action, :data_id, :html])
    |> validate_required([:action, :data_id, :html])
  end

  def render(template, opts \\ []) do
    Phoenix.View.render_to_string(PhoenixChina.NotificationView, template, opts)
  end

  def publish(action, user_id, operator_id, data_id, notification_html) do
    notification_struct = %__MODULE__{
      user_id: user_id,
      operator_id: operator_id,
      action: action,
      data_id: data_id,
      html: notification_html
    }

    case PhoenixChina.Repo.insert(notification_struct) do
      {:ok, notification} ->
        PhoenixChina.Endpoint.broadcast(
          "notifications:" <> (notification.user_id |> Integer.to_string),
          ":msg",
          %{"body" => notification_html}
        )
      {:error, struct} -> struct
    end
  end
end
