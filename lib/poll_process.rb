module PollProcess
  def self.included(base)
    base.class_eval {
      alias_method_chain :process, :poll
      attr_accessor :submitted_polls
    }
  end
  
  def poll_cookies(cookie_hash)
    result = []
    cookie_hash.to_a.select { |c| c[0].starts_with?('poll_') }.each do |c|
      result << c[0].gsub('poll_','').to_i
    end
    result
  end

  def process_with_poll(request, response)
    # check the cookies and set the polls that have been submitted
    self.submitted_polls = poll_cookies(request.cookies)
    process_without_poll(request, response)
  end
  
end
