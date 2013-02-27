class PollResponseController < ApplicationController
  no_login_required
  skip_before_filter :verify_authenticity_token

  def create
    @page = Page.find(params[:page_id])
    @page.request, @page.response = request, response

    poll = Poll.find(params[:poll_id])
    current_poll = Poll.find_current
    
    # Use cookies instead of sessions, to limit multiple responses on same poll
    # assign the submitted polls from cookies to the current page so we can
    # pass it off to our radius tags
    @page.submitted_polls = @page.poll_cookies(cookies)

    if !@page.submitted_polls.include?(poll.id) && (!current_poll || current_poll.id == poll.id)

      begin
        poll_cookie_duration = eval(config['polls.cookie_duration']).from_now || 1.month.from_now
      rescue Exception => exc
        poll_cookie_duration = 1.month.from_now
      end

      cookies["poll_#{poll.id.to_s}"] = { :value => "#{@page.id}", :expires => poll_cookie_duration }
      @page.submitted_polls << poll.id

      poll_response = Option.find(params[:response_id])
      poll.submit_response(poll_response)
    end    

    redirect_to @page.url
  end

end
