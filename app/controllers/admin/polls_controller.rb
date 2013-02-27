class Admin::PollsController < Admin::ResourceController

  model_class Poll
  paginate_models
  # only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
  #   :when => [:designer, :admin],
  #   :denied_url => { :controller => 'admin/pages', :action => 'index' },
  #   :denied_message => 'You must have designer privileges to perform this action.'

  def clear_responses
    if @poll = Poll.find(params[:id])
      @poll.clear_responses
      flash[:notice] = t('polls_controller.responses_cleared', :poll => @poll.title)
    end
    redirect_to :action => :index
  end

  protected

    def load_models
      # Order polls by descending date, then alphabetically by title
      self.models = model_class.all(:order => Poll.send(:sanitize_sql_array, [ "COALESCE(start_date, ?) DESC, title", Date.new(1900, 1, 1) ])).paginate(pagination_parameters)
    end

end
