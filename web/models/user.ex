defmodule PhoenixChina.User do
  use PhoenixChina.Web, :model

  alias Ecto.Changeset
  alias PhoenixChina.{Repo}

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :username, :string
    field :nickname, :string
    field :avatar, :string
    field :bio, :string
    field :collect_count, :integer, default: 0
    field :follower_count, :integer, default: 0
    field :followed_count, :integer, default: 0
    field :unread_notifications_count, :integer, default: 0
    field :is_admin, :boolean, default: false

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :old_password, :string, virtual: true
    field :token, :string, virtual: true
    field :luotest_response, :string, virtual: true

    has_many :github, PhoenixChina.UserGithub

    timestamps()
  end

  @regex_email ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
  @regex_mobile ~r/1\d{10}$/

  def changeset(action, struct, params \\ %{})

  def changeset(:edit, struct, params) do
    struct
    |> cast(params, [:avatar, :nickname])
    |> validate_required([:avatar, :nickname], message: "不能为空")
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
  end

  def changeset(:signup, struct, params) do
    struct
    |> cast(params, [:email, :password, :username, :luotest_response])
    |> validate_required([:email, :password, :username], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> unique_constraint(:email, message: "邮箱已被注册啦！")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_exclusion(:username, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> validate_format(:username, ~r/^[a-zA-Z][\w\.\-]{3,17}$/, message: "只允许字母开头，由字母、数字、\"_\"、\".\"、\"-\"组成，4-18位。")
    |> unique_constraint(:username, message: "用户名已被注册啦！")
    |> put_password_hash(:password)
    |> put_avatar
  end

  def changeset(:signin, struct, params) do
    struct
    |> cast(params, [:email, :password, :luotest_response])
    |> validate_required([:email, :password], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_user_exist(:email)
    |> validate_password(:password)
  end

  def changeset(:account, struct, params) do
    struct
    |> cast(params, [:old_password, :password, :password_confirmation])
    |> validate_required([:old_password, :password, :password_confirmation], message: "不能为空")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_confirmation(:password, message: "两次密码输入不一致")
    |> validate_password(:old_password)
    |> put_password_hash(:password)
  end

  def changeset(:profile, struct, params) do
    struct
    |> cast(params, [:nickname, :bio], [:avatar])
    |> validate_length(:nickname, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> validate_length(:bio, max: 140)
  end

  def changeset(:github, struct, params) do
    struct
    |> cast(params, [:email, :password_hash, :username, :nickname, :avatar, :bio])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> unique_constraint(:nickname)
  end

  def changeset(:password_reset_for_email, struct, params) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> load_user(:email)
  end

  def changeset(:password_reset, struct, params) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, mix: 6, max: 128)
    |> validate_confirmation(:password)
    |> put_password_hash(:password)
  end

  # defp validate_luotest_response(changeset) do
  #   case changeset.changes do
  #     %{"luotest_response": luotest_response} ->
  #       case PhoenixChina.Luosimao.captcha_verify?(luotest_response) do
  #         true ->
  #           changeset
  #         false ->
  #           changeset
  #           |> Ecto.Changeset.add_error(:luotest_response, "人机识别验证失败")
  #       end
  #     _ ->
  #     changeset
  #   end
  # end

  def validate_user_exist(%Ecto.Changeset{valid?: true} = changeset, field) do
    value = get_field(changeset, field)

    user = case field do
      :email ->
         __MODULE__ |> Repo.get_by(email: value)
    end

    case user do
      nil ->
        changeset
        |> add_error(field, "用户不存在")
      user ->
        changeset
        |> put_change(:user, user)
    end
  end

  def validate_user_exist(%Ecto.Changeset{valid?: false} = changeset, _field) do
    changeset
  end

  def validate_password(%Ecto.Changeset{valid?: true} = changeset, field) do
    user = get_field(changeset, :user) || changeset.data
    password = get_field(changeset, field)

    case user.password_hash do
      nil -> changeset |> add_error(field, "您未设置密码，请使用第三方登陆")
      _ ->
        case check_password?(password, user.password_hash) do
          true ->
            changeset
          false ->
            changeset
            |> add_error(field, "密码错误")
        end
    end
  end

  def validate_password(%Ecto.Changeset{valid?: false} = changeset, _field) do
    changeset
  end

  def put_password_hash(%Ecto.Changeset{valid?: true} = changeset, field) do
    value = get_field(changeset, field)

    changeset
    |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(value))
  end

  def put_password_hash(%Ecto.Changeset{valid?: false} = changeset, _field) do
    changeset
  end

  def check_password?(password, password_hash) do
    password |> Comeonin.Bcrypt.checkpw(password_hash)
  end

  def put_avatar(%Ecto.Changeset{valid?: true} = changeset) do
    email = get_field(changeset, :email)
    |> String.trim
    |> String.downcase

    email_md5 = :crypto.hash(:md5, email)
    |> Base.encode16(case: :lower)

    avatar = "https://gravatar.tycdn.net/avatar/#{email_md5}?d=wavatar&s=#200"

    changeset |> put_change(:avatar, avatar)
  end

  def put_avatar(%Ecto.Changeset{valid?: false} = changeset) do
    changeset
  end

  @doc """
  通过账号获取用户，支持用户名，邮箱，手机号
  """
  def get_by_account(account) do
    cond do
      String.match?(account, @regex_email) ->
        __MODULE__ |> Repo.get_by(email: account)
      String.match?(account, @regex_mobile) ->
        __MODULE__ |> Repo.get_by(mobile: account)
      true ->
        __MODULE__ |> Repo.get_by(username: account)
    end
  end

  @doc """
  加载用户
  """
  def load_user(%Changeset{valid?: true} = changeset, field) do
    case changeset |> get_field(field) |> get_by_account do
      nil -> changeset |> add_error(field, "用户不存在")
      user -> %{changeset | data: user}
    end
  end

  def load_user(%Changeset{valid?: false} = changeset, _field) do
    changeset
  end

  def generate_token(user, token_name \\ "user_id") do
    Phoenix.Token.sign(PhoenixChina.Endpoint, token_name, user.id)
  end

  def validate_token(token, token_name \\ "user_id", max_age \\ 60 * 60 * 12) do
    Phoenix.Token.verify(PhoenixChina.Endpoint, token_name, token, max_age: max_age)
  end
end
