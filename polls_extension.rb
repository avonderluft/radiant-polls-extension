require_dependency 'application_controller'

class PollsExtension < Radiant::Extension
  
  version "#{File.read(File.expand_path(File.dirname(__FILE__)) + '/VERSION')}"
  description 'Radiant gets polls.  Forked from nuex (Chase James) to use cookies.'
  url 'https://github.com/avonderluft/radiant-polls-extension'

  def activate
    
    unless defined?(CacheByPage)
      puts "The Radiant cache_by_page extension is recommended, to set shorter caching times on pages with polls"
    end
  
    tab 'Content' do
      add_item 'Polls', '/admin/polls'
    end
    
    if Radiant::Config.table_exists?
      Radiant::Config['paginate.url_route'] = '' unless Radiant::Config['paginate.url_route']
      PollsExtension.const_set('UrlCache', Radiant::Config['paginate.url_route'])
    end

    Page.send :include, PollTags
    Page.send :include, PollProcess
    
    Radiant::AdminUI.class_eval do
      attr_accessor :poll
      alias_method "polls", :poll
    end
    admin.poll = load_default_poll_regions

  end
  
  def load_default_poll_regions
    OpenStruct.new.tap do |poll|
      poll.edit = Radiant::AdminUI::RegionSet.new do |edit|
        edit.main.concat %w{edit_header edit_form}
        edit.form_bottom.concat %w{edit_buttons edit_timestamp}
      end
      poll.index = Radiant::AdminUI::RegionSet.new do |index|
        index.top.concat %w{}
        index.thead.concat %w{name_header date_header responses_header actions_header}
        index.tbody.concat %w{name_cell date_cell responses_cell actions_cell}
        index.bottom.concat %w{new_button}
      end
      poll.new = poll.edit
    end
  end

end
