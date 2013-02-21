require 'spec_helper'

describe Page, "with polls", :type => :integration do
  dataset :pages

  before :all do
    @cache_dir = "#{RAILS_ROOT}/tmp/cache"
    @cache_file = "#{@cache_dir}/_site-root.yml"
  end

  before :each do
    @page = pages(:home)
    ResponseCache.defaults[:directory] = @cache_dir
    ResponseCache.defaults[:perform_caching] = true
    ResponseCache.defaults[:expire_time] = 1.day
    @cache = ResponseCache.instance
    @cache.clear unless @cache.defaults[:directory] == '/'
  end

  describe "- fetch of page without a poll" do
    it "should render the page and cache it with defaults" do
      navigate_to @page.url
      response.should be_success
      response.cache_timeout.should be_nil
      @cache.response_cached?(@page.url).should be_true
      YAML.load_file(@cache_file)['expires'].should be_close(@cache.defaults[:expire_time].from_now, 0.1)
    end
  end
    
  ["single poll", "collection of polls"].each do |test|
    
    describe "- fetch of page with a #{test}" do

      before :each do
        Poll.create(:id => 42, :title => "My Older Poll", :response_count => 0, :start_date => 2.days.ago)
        Poll.create(:id => 43, :title => "My Newer Poll", :response_count => 0, :start_date => 1.day.ago)
        poll_tag = "<r:poll><r:title/></r:poll>"
        if test.eql?("collection of polls")
          poll_tag = "<r:polls><r:each:poll><r:title/></r:each:poll></r:polls>"
        end
        @part = PagePart.find_by_page_id_and_name(@page, 'body')
        @part.content += poll_tag
        @part.save
        navigate_to @page.url
        @first_cached_page_expire_date = YAML.load_file(@cache_file)['expires']
      end

      it "should render the page and cache it with defaults" do
        response.should be_success
        response.cache_timeout.should be_nil
        @cache.response_cached?(@page.url).should be_true
        YAML.load_file(@cache_file)['expires'].should be_close(@cache.defaults[:expire_time].from_now, 0.1)
      end

      it "should expire the cached page on reload, and re-cache it, since it has a poll" do
        navigate_to @page.url
        response.should be_success
        response.cache_timeout.should be_nil
        response.body.include?(Poll.marker).should be_true
        @cache.response_cached?(@page.url).should be_true
        YAML.load_file(@cache_file)['expires'].should be > @first_cached_page_expire_date
      end

    end

  end

end
