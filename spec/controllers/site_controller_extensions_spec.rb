require 'spec_helper'
require 'site_controller'

SiteController.module_eval { def rescue_action(e); raise e; end }

describe SiteController, "(Extended) - with poll additions" do
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

  it "should include the extension module" do
    SiteController.included_modules.should include(Polls::SiteControllerExtensions)
  end

  it "should add the before filter" do
    SiteController.before_filters.should be_any {|f| f == :expire_cached_page_with_polls }
  end

  it "should run the before filter" do
    self.controller.should_receive(:expire_cached_page_with_polls)
    get :show_page, :url => @page.url
  end
  
  it "should handle added and extended methods" do
    @page.should respond_to(:poll_cookies)
    @page.should respond_to(:process_with_poll)
    @page.should respond_to(:process_without_poll)
    @page.should have(:no).errors_on(:process_with_poll)
  end

  it "page should be valid" do
    @page.should be_valid
  end

  it "page should cache by default" do
    @page.cache?.should == true 
  end

end
