class ExperimentsController < ApplicationController
  def index
    add_breadcrumb "Experiments", experiments_path
  end
end