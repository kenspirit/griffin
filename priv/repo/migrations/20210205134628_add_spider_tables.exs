defmodule Griffin.Repo.Migrations.AddSpiderTables do
  use Ecto.Migration

  def change do
    create table(:spider_configs) do
      add :name, :string
      add :type, :string
      add :root_url, :string
      add :worker_count, :integer, default: 1
      add :crawl_interval, :integer, default: 3000 # 3s
      add :revisit_interval, :integer, default: 24 * 3600 * 1000 # 1d
      add :disabled, :boolean, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create table(:pages) do
      add :spider_type, :string
      add :spider_name, :string
      add :url, :string
      add :summary, :string
      add :keywords, :string
      add :content, :string
      add :size, :integer
      add :invalid, :boolean, default: false
      add :success, :boolean, default: false
      add :failed_reason, :string
      add :img_url, :string
      add :video_url, :string
      add :ext_link_url, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
