defmodule Lolth.Spider.Config do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    name:  String.t(),
    type: String.t(),
    root_url: String.t(),
    worker_count: integer,
    crawl_interval: integer,
    revisit_interval: integer,
    disabled: boolean
  }

  @derive {Jason.Encoder, only: [:name, :type, :root_url, :worker_count, :crawl_interval, :revisit_interval, :disabled]}
  schema "spider_configs" do
    field :name, :string
    field :type, :string
    field :root_url, :string
    field :worker_count, :integer, default: 1
    field :crawl_interval, :integer, default: 3000 # 3s
    field :revisit_interval, :integer, default: 24 * 3600 * 1000 # 1d
    field :disabled, :boolean, default: false
    field :params, :map, default: %{}

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(config, attrs \\ %{}) do
    config
    |> cast(attrs, [:name, :type, :root_url, :worker_count, :crawl_interval, :revisit_interval, :disabled, :params])
    |> validate_required([:name, :type, :root_url])
  end

  def search_changeset(config, attrs \\ %{}) do
    config
    |> cast(attrs, [:name, :type, :disabled])
  end
end
