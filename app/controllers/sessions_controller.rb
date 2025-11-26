class SessionsController < ApplicationController
  def new
  end

  def create
    render html: "<h1>Logged In</h1>".html_safe
  end
end