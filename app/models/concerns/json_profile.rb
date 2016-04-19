module JsonProfile
  extend ActiveSupport::Concern

  def profile_field(json_xpath)
    fields = json_xpath.split('.')
    if profile && fields.inject(profile) { |h,k| h[k] if h } 
      fields.inject(profile) { |h,k| h[k] if h } 
    end 
  end
end
