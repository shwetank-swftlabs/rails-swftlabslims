module Experiments
  class BaseController < ApplicationController
    before_action :set_experiments_breadcrumbs_root

    private

    def set_experiments_breadcrumbs_root
      add_breadcrumb "Experiments", experiments_path
    end
  end

  class NopProcessesController < BaseController
    before_action :set_nop_breadcrumbs_root

    def index
    end

    def show
    end

    private
    def set_nop_breadcrumbs_root
      add_breadcrumb "NOP Processes", nop_processes_path
    end
  end
end