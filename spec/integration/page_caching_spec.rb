require 'spec_helper'

describe Page, "with and without polls present" do
  
  dataset :pages

  before :all do
    FileUtils.chdir RAILS_ROOT
    @cache_dir = "#{RAILS_ROOT}/tmp/cache"
    @cache_file = "#{@cache_dir}/meta/*/*"

  end

  before :each do
    @page = pages(:home)
    @default = 1.day
    SiteController.page_cache_directory = @cache_dir
    SiteController.perform_caching = true
    SiteController.cache_timeout = @default
    @expire_mins = @default.to_i/60
    @cache = Radiant::Cache
    @cache.clear
  end
  
  def page_is_cached(page)
    if response.nil?
      @cache.clear
      false
    else 
      ! response.headers['Cache-Control'].include?('no-cache')
    end
  end

  def cache_expires
    Time.now + `cat #{@cache_file}`.split('max-age=')[1].split(',')[0].to_i rescue nil
  end

  describe "- fetch of page without a poll" do
    it "should render a page with default caching" do
      get "#{@page.slug}"
      response.should be_success
      response.cache_timeout.should be_nil
      page_is_cached(@page).should be_true
      response.headers['Cache-Control'].should == "max-age=#{@default}, public"
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
        get "#{@page.slug}"
        @first_cached_page_expire_time = cache_expires
      end

      it "should render the page and cache it with defaults" do
        response.should be_success
        response.cache_timeout.should be_nil
        cache_expires.should be_close(@expire_mins.minutes.from_now, 30)
      end

    end

  end

end
