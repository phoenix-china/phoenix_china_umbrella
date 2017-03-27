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
    changeset = Session.changeset(%Session{}, attrs)
    
    if changeset.valid? do
      {:ok, Session.get_user(changeset)}
    else
      {:error, changeset}
    end
  end
end