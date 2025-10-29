class ApplicationRecord < ActiveRecord::Base
  # Base class for all our models
  # Rails won’t make a table just for this class
  primary_abstract_class
end
