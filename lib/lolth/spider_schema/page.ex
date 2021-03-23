defmodule Lolth.Spider.Page do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    id: any(),
    spider_type:  String.t(),
    spider_name: String.t(),
    url: String.t(),
    summary: String.t(),
    keywords: String.t(),
    content: String.t(),
    size: integer,
    invalid: boolean,
    success: boolean,
    failed_reason: String.t(),
    img_url: String.t(),
    video_url: String.t(),
    ext_link_url: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t()
  }

  # @primary_key {:id, :id, autogenerate: false}
  @derive Jason.Encoder
  schema "pages" do
    field :spider_type, :string
    field :spider_name, :string
    field :url, :string
    field :summary, :string
    field :keywords, :string
    field :content, :string
    field :size, :integer
    field :invalid, :boolean, default: false
    field :success, :boolean, default: false
    field :failed_reason, :string
    field :img_url, :string
    field :video_url, :string
    field :ext_link_url, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(page, attrs) do
    {fields, required} =
      case attrs do
        %{"success" => true} ->
          {
            [:id, :spider_type, :spider_name, :url, :summary, :keywords, :content, :size, :img_url, :video_url, :ext_link_url, :success, :failed_reason, :invalid],
            [:spider_type, :spider_name, :url, :content]
          }
        %{"invalid" => true} ->
          {
            [:id, :spider_type, :spider_name, :url, :invalid, :success, :failed_reason],
            [:spider_type, :spider_name, :url]
          }
        _ ->
          {
            [:id, :spider_type, :spider_name, :url, :failed_reason],
            [:spider_type, :spider_name, :url]
          }
      end

    page
    |> cast(attrs, fields)
    |> validate_required(required)
  end
end
