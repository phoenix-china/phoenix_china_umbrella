defmodule PhoenixChina.Qiniu do
  @config Application.get_env(:qiniu, Qiniu)

  def upload(file) do
    filename = generate_filename(file)
    upload(file, filename)
  end

  def upload(file, filename) do
    put_policy = Qiniu.PutPolicy.build(Keyword.get(config, :resource))
    response = Qiniu.Uploader.upload put_policy, file.path, key: filename

    case response.body |> Poison.Parser.parse! do
      %{"hash" => hash, "key" => key} ->
        {:ok, %{
          hash: hash,
          key: key,
          url: "#{@config[:domain]}/#{filename}"
        }}
      errors ->
        {:error, errors}
    end
  end

  def filename_and_url(file) do
    filename = generate_filename(file)
    [filename, "#{@config[:domain]}/#{filename}"]
  end

  defp generate_filename(file) do
    filetype = file.filename |> String.split(".") |> List.last
    str = "#{file.content_type}#{file.path}#{file.filename}"

    filename = :crypto.hash(:md5, str)
    |> Base.encode16(case: :lower)

    "#{filename}.#{filetype}"
  end
end
