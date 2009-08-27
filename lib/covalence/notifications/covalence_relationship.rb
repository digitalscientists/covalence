module Covalence
	module Relationship
		def self.included(model)
			model.extend(ClassMethods)
			model.class_eval do
				belongs_to	:parent, :polymorphic => true
				belongs_to	:child, :polymorphic => true

				validates_presence_of :parent
				validates_presence_of :child
			end
		end
	
		module ClassMethods
		
			def find_by_parent_and_child(parent, child)
				first(:conditions => [
					'parent_type = ? and parent_id =? and child_type = ? and child_id = ?',
					parent.class.to_s, 
					parent.id, 
					child.class.to_s, 
					child.id
				])
			end
		end
		
	end
	
	# select * from users join friendships on (parent_type = :type and parent_id = :id) or (child_type = :type and child_id = :id)
	#	 where (parent_id != #{id} and users.id = parent_id) or (child_id != {#id} and users.id = child_id)
	
	module RelationshipMethods
		def self.included(base)
			base.class_eval do
				class << self
					def has_relationship relationship, options, &extension
						klass = options[:through].to_s.classify
						
						send(:has_many, "_#{relationship.to_s}_with", {:as => :parent, :class_name => klass.to_s})
						send(:has_many, "_#{relationship.to_s.singularize}_of", {:as => :child, :class_name => klass.to_s})
						send(:has_many, "#{relationship.to_s}_with", {:through => "_#{relationship.to_s}_with", :source => :child, :source_type => self.to_s})
						send(:has_many, "#{relationship.to_s.singularize}_of", {:through => "_#{relationship.to_s.singularize}_of", :source => :parent, :source_type => self.to_s})
						
						define_method(relationship) do |*options|
							options = options.first || {}
							opts = {}.merge(options)
							send("#{relationship.to_s}_with").all(opts) | send("#{relationship.to_s.singularize}_of").all(opts)
						end
						
						define_method("#{relationship}_count") do |*options|
							options = options.first || {}
							opts = {}.merge(options)
							send("#{relationship.to_s}_with").count(opts) + send("#{relationship.to_s.singularize}_of").count(opts)
						end

					end
				end
			end
		end
	end
	
		
end

ActiveRecord::Base.send(:include, Covalence::RelationshipMethods)