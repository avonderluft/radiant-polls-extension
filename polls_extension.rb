class PollsExtension < Radiant::Extension
  
  version "#{File.read(File.expand_path(File.dirname(__FILE__)) + '/VERSION')}"
  description 'Radiant gets polls.'
  url 'https://github.com/avonderluft/radiant-polls-extension'

  def activate
    require_dependency 'application_controller'
    tab 'Content' do
      add_item 'Polls', '/admin/polls', :after => 'Pages'
    end
    if Radiant::Config.table_exists?
      Radiant::Config['paginate.url_route'] = '' unless Radiant::Config['paginate.url_route']
      PollsExtension.const_set('UrlCache', Radiant::Config['paginate.url_route'])
    end
    Page.send :include, PollTags
    Page.send :include, PollProcess
    Page.send :include, PollPageExtensions
    Page.send :include, ActionView::Helpers::TagHelper  # Required for pagination
  end

end
