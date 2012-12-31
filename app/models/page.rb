class Page < ActiveRecord::Base
  attr_accessible :parent_id, :content, :name

  before_destroy :move_orphans

  has_ancestry orphan_strategy: :restrict

  def move_orphans
    unless self.class.orphan_strategy == :adopt
      descendants.all.each do |descendant|
        descendant.without_ancestry_callbacks do
          new_ancestry = descendant.ancestor_ids.delete_if { |x| x == self.id }.join("/")
          descendant.update_attribute descendant.class.ancestry_column, new_ancestry || nil
        end
      end
    end
  end
end
