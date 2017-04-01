defmodule PhoenixChina.Models.User do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :avatar, :string
    field :email, :string
    field :nickname, :string
    field :password_hash, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    timestamps()
  end

  @required_fields ~w(email nickname password)a
  @optional_fields ~w()a
  @regex_email ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  def changeset(struct, params) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields, message: "不能为空")
    |> unique_constraint(:email, name: :users_lower_email_index, message: "邮箱已存在")
    |> validate_format(:email, @regex_email, message: "请输入正确的邮箱地址")
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已存在")
    |> validate_length(:password, min: 6, max: 128, message: "密码长度6-128位")
    |> put_password_hash
    |> put_avatar
  end

  def changeset_password_reset(struct, params) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation], message: "不能为空")
    |> validate_length(:password, mix: 6, max: 128, message: "密码长度6-128位")
    |> validate_confirmation(:password, message: "两次输入密码不一致")
    |> put_password_hash
  end

  defp put_password_hash(%{valid?: false} = changeset), do: changeset
  defp put_password_hash(changeset) do
    password_hash = 
      changeset
      |> get_field(:password)
      |> Comeonin.Bcrypt.hashpwsalt

    put_change(changeset, :password_hash, password_hash)
  end
  
  defp put_avatar(%{valid?: false} = changeset), do: changeset
  defp put_avatar(changeset) do
    avatar =
      changeset
      |> get_field(:email)
      |> String.trim
      |> String.downcase
      |> generate_avatar
      
    put_change(changeset, :avatar, avatar)
  end

  defp generate_avatar(email) do
    email_md5 = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://gravatar.tycdn.net/avatar/#{email_md5}?d=wavatar&s=#200"
  end
end
