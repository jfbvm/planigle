class IterationTotal < Total
  belongs_to :iteration

  # This should be overridden in subclasses.
  def self.id_field
    :iteration_id
  end
end