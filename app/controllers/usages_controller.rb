class UsagesController < ApplicationController
  def index
    @usageable = find_polymorphic_parent
    @pagy, @usages = pagy(@usageable.usages.order(updated_at: :desc))
  end

  def create
    usageable = find_polymorphic_parent
    @usage = usageable.usages.new(usage_params)

    if @usage.save
      redirect_to_polymorphic_parent(usageable, tab: :use_records, flash_hash: { notice: "Use record created successfully" }, status: :see_other)
    else
      redirect_to_polymorphic_parent(usageable, tab: :use_records, flash_hash: { alert: "Failed to create use record: #{@usage.errors.full_messages.join(", ")}" }, status: :see_other)
    end
  end

  def update
    usageable = find_polymorphic_parent
    @usage = usageable.usages.find(params[:id])
    if @usage.update(update_usage_params)
      redirect_to_polymorphic_parent(usageable, tab: :use_records, flash_hash: { notice: "Use record updated successfully" }, status: :see_other)
    else
      redirect_to_polymorphic_parent(usageable, tab: :use_records, flash_hash: { alert: "Failed to update use record: #{@usage.errors.full_messages.join(", ")}" }, status: :see_other)
    end
  end

  private
  def usage_params
    params.require(:use_record).permit(:amount, :purpose, :created_by, :created_at)
  end

  def update_usage_params
    params.require(:usage).permit(:is_active, :amount, :purpose, :created_at)
  end
end