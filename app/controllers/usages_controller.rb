class UsagesController < ApplicationController
  def index
    @usageable = find_polymorphic_parent
    @pagy, @usages = pagy(@usageable.usages.order(updated_at: :desc), items: 5)
  end

  def create
    usageable = find_polymorphic_parent
    @usage = usageable.usages.new(usage_params)

    if @usage.save
      redirect_to_polymorphic_parent(usageable, tab: :use_records, flash_hash: { notice: "Use record created successfully" })
    else
      redirect_to_polymorphic_parent(usageable, tab: :use_records, flash_hash: { alert: "Failed to create use record: #{@usage.errors.full_messages.join(", ")}" })
    end
  end

  private
  def usage_params
    params.require(:use_record).permit(:amount, :purpose, :created_by, :created_at)
  end
end