class HomeController < ApplicationController
  def index
    if Rails.application.secrets.google_analytics
      @analytics = {'key' => Rails.application.secrets.google_analytics}
    end
  end
end