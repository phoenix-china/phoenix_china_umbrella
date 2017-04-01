defmodule PhoenixChina.PasswordResetContext do
  alias PhoenixChina.Models.PasswordReset

  @doc """
  with {:ok, user} <- PasswordResetContext.create(attrs) do
    conn
    |> assign(:user, user)
    |> redirect(to: "/")
  end
  """
  def create(attrs \\ %{}) do
    changeset = change_password_reset(attrs)
    
    if changeset.valid? do
      {:ok, PasswordReset.get_user(changeset)}
    else
      {:error, %{changeset | action: :create}}
    end
  end

  def change_password_reset(attrs \\ %{}) do
    %PasswordReset{}
    |> PasswordReset.changeset(attrs)
  end
end