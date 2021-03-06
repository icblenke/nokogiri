require "helper"
require File.join(File.dirname(__FILE__),"load_files")

class TestAlter < Nokogiri::TestCase
  include Nokogiri

  def setup
    super
    @basic = Nokogiri::HTML.parse(TestFiles::BASIC)
  end

  def test_before
    test0 = "<link rel='stylesheet' href='test0.css' />"
    @basic.at("link").before(test0)
    assert_equal 'test0.css', @basic.at("link").attributes['href'].to_s
  end

  def test_after
    test_inf = "<link rel='stylesheet' href='test_inf.css' />"
    @basic.search("link")[-1].after(test_inf)
    assert_equal 'test_inf.css', @basic.search("link")[-1]['href']
  end

  def test_wrap
    ohmy = (@basic/"p.ohmy").wrap("<div id='wrapper'></div>")
    assert_equal 'wrapper', ohmy[0].parent['id']
    assert_equal 'ohmy', Nokogiri(@basic.to_html).at("#wrapper").children[0]['class']
  end

  def assert_changed original, selector, set, &block
    assert set.all?(&block)
    assert Nokogiri(original.to_html).search(selector).all?(&block)
  end
end
