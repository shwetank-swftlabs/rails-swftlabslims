class MakePolymorphicParentOptionalInLibrarySamples < ActiveRecord::Migration[8.1]
  def change
    change_column_null :library_samples, :library_sampleable_id, true
    change_column_null :library_samples, :library_sampleable_type, true
  end
end
