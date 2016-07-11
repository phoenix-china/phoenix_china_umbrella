defmodule PhoenixChina.User do
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :avatar, :string
    field :nickname, :string
    field :bio, :string
    field :collect_count, :integer, default: 0
    field :follower_count, :integer, default: 0
    field :followed_count, :integer, default: 0

    field :password, :string, virtual: true
    field :old_password, :string, virtual: true
    field :password_confirm, :string, virtual: true
    field :token, :string, virtual: true

    timestamps()
  end

  def changeset(action, struct, params \\ %{})

  def changeset(:edit, struct, params) do
    struct
    |> cast(params, [:avatar, :nickname])
    |> validate_required([:avatar, :nickname], message: "不能为空")
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦！")
  end

  def changeset(:signup, struct, params) do
    struct
    |> cast(params, [:email, :password, :nickname])
    |> validate_required([:email, :password, :nickname], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> unique_constraint(:email, message: "邮箱已被注册啦！")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦！")
  end

  def changeset(:signin, struct, params) do
    struct
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> validate_length(:password, min: 6, max: 128)
  end

  def changeset(:account, struct, params) do
    struct
    |> cast(params, [:old_password, :password, :password_confirm])
    |> validate_required([:old_password, :password, :password_confirm], message: "不能为空")
    |> validate_length(:password, min: 6, max: 128)
  end

  def changeset(:password_forget, struct, params) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
  end

  def changeset(:password_reset, struct, params) do
    struct
    |> cast(params, [:token, :password, :password_confirm])
    |> validate_required([:token, :password, :password_confirm], message: "不能为空")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_equal_to(:password_confirm, :password)
    |> validate_token(:token, "user_id", 60 * 60 * 24)
  end

  def changeset(:profile, struct, params) do
    struct
    |> cast(params, [:nickname, :bio])
    |> validate_required([:nickname], message: "不能为空")
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦，请更换别的昵称试试")
    |> validate_length(:bio, max: 140)
  end

  def put_password_hash(changeset) do
    password_hash = changeset.changes.password
    |> Comeonin.Bcrypt.hashpwsalt

    changeset
    |> put_change(:password_hash, password_hash)
  end

  def check_password(password, password_hash) do
    password
    |> Comeonin.Bcrypt.checkpw(password_hash)
  end

  def check_password?(password, password_hash) do
    check_password(password, password_hash)
  end

  def validate_password(changeset, field) do
    password = get_field(changeset, field)
    password_hash = get_field(changeset, :password_hash)

    case check_password?(password, password_hash) do
      false ->
        changeset
        |> add_error(field, "密码错误")
      true ->
        changeset
    end
  end

  def validate_equal_to(changeset, field, to_field) do
    data1 = get_field(changeset, field)
    data2 = get_field(changeset, to_field)

    case data1 == data2 do
      false ->
        changeset
        |> add_error(field, "两次输入不一致")
      true ->
        changeset
    end
  end

  def validate_token(changeset, field, token_name, max_age) do
    token = get_field(changeset, field)
    case Phoenix.Token.verify(PhoenixChina.Endpoint, token_name, token, max_age: max_age) do
      {:ok, user_id} ->
        user = (from __MODULE__, where: [id: ^user_id]) |> first |> PhoenixChina.Repo.one!
        changeset
        |> Ecto.Changeset.put_change(:user, user)
      {:error, :invalid} ->
        changeset
        |> Ecto.Changeset.add_error(field, "token不正确，请重新申请重置密码！")
      {:error, :expired} ->
        changeset
        |> Ecto.Changeset.add_error(field, "token已过期，请重新申请重置密码！")
    end
  end

  def new_list do
    query = from __MODULE__, order_by: [desc: :inserted_at], limit: 10
    query |> Repo.all
  end

  def generate_token(user, token_name \\ "user_id") do
    Phoenix.Token.sign(PhoenixChina.Endpoint, token_name, user.id)
  end

  def inc(%__MODULE__{:id => user_id}, :collect_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [collect_count: 1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => user_id}, :collect_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [collect_count: -1])
    |> Repo.update_all([])
  end

  def inc(%__MODULE__{:id => user_id}, :follower_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [follower_count: 1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => user_id}, :follower_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [follower_count: -1])
    |> Repo.update_all([])
  end

  def inc(%__MODULE__{:id => user_id}, :followed_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [followed_count: 1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => user_id}, :followed_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [followed_count: -1])
    |> Repo.update_all([])
  end
end
