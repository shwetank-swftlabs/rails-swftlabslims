class UsagesController < ApplicationController
  before_action :set_usageable, only: [:create]

  def create
    @usage = @usageable.usages.new(usage_params)

    if @usage.save
      redirect_to polymorphic_path(@usageable, tab: :use_records), notice: "Use record created successfully"
    else
      redirect_to polymorphic_path(@usageable, tab: :use_records), alert: "Failed to create use record"
    end
  end

  private

  def set_usageable
    params.each do |key, value|
      next unless key.to_s =~ /(.+)_id$/
  
      basename = $1.classify  # e.g. "Equipment", "Chemical"
      klass = basename.safe_constantize
  
      # Try Inventory namespace since routes are nested under inventory
      if klass.nil?
        klass = "Inventory::#{basename}".safe_constantize
      end
  
      # Fallback: search for namespaced constants in other namespaces
      if klass.nil?
        klass = ObjectSpace.each_object(Class).find do |c|
          c.name&.end_with?("::#{basename}")
        end
      end
  
      return @usageable = klass.find(value) if klass
    end
  
    raise "Usageable not found"
  end
  
  def usage_params
    params.require(:use_record).permit(:amount, :purpose, :created_by, :created_at)
  end


  def redirect_to_usageable(flash_hash = {})
    redirect_to polymorphic_url(@usageable, { tab: :usages }), flash: flash_hash
  end
end