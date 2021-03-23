defmodule Lolth.SpiderHelper do
  alias Lolth.Spider.Page

  def crawlable?(page) when is_nil(page) do
    true
  end

  def crawlable?(%Page{success: true}) do
    false
  end

  def crawlable?(%Page{invalid: true}) do
    false
  end

  def crawlable?(%Page{invalid: false, success: false}) do
    true
  end

  def crawlable?(_) do
    false
  end
end
