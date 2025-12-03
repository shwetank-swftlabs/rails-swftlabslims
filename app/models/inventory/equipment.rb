module Inventory
  class Equipment < ApplicationRecord
    self.table_name = "equipments"
    include DefaultDescOrder
    default_desc :updated_at

    include QrLabelable

    belongs_to :equipment_type, class_name: "Admin::EquipmentType", optional: false

    has_many :images, as: :attachable, dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy

    has_many :nop_processes, class_name: "Experiments::NopProcess", foreign_key: "reactor_id", dependent: :destroy
    has_one :last_nop_process, -> { order(created_at: :desc) },
    class_name: "Experiments::NopProcess",
    foreign_key: :reactor_id

    validates :name, presence: true, uniqueness: true
    validates :code, presence: true, uniqueness: true
    validates :created_by, presence: true
    
    def default_label_title
      name.upcase
    end

    def self.reactors
      where(equipment_type: "reactor").map do |reactor|
        reactor.as_json.merge(
          "last_nop_process" => last_nop_process(reactor.id).as_json
        )
      end
    end
    
    def self.last_nop_process(reactor_id)
      Experiments::NopProcess.where(reactor_id: reactor_id).order(created_at: :desc).first
    end
  end
end