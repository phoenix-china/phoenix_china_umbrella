defmodule PhoenixChina.SessionContext do
  alias PhoenixChina.Models.Session

  @doc """
  with {:ok, user} <- SessionContext.create(attrs) do
    conn
    |> assign(:user, user)
    |> redirect(to: "/")
  end
  """
  def create(attrs \\ %{}) do
    changeset = change_session(attrs)
    
    if changeset.valid? do
      {:ok, Session.get_user(changeset)}
    else
      {:error, %{changeset | action: :create}}
    end
  end

  def change_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
  end
end