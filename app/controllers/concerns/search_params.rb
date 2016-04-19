module SearchParams
  private

  def has_search_params?
    params[:q] || params[:aq]
  end 
end
