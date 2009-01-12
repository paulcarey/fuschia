require 'rubygems'
require 'relaxdb'

class User < RelaxDB::Document
  
  property :name
  
  has_many :comments, :class => "Comment", :known_as => :author
  has_many :posts, :class => "Post", :known_as => :author

  references :best_friend
  
end

class Post < RelaxDB::Document
  
  property :created_at
  property :contents
  
  belongs_to :author
  has_many :comments, :class => "Comment"
  
end

class Comment < RelaxDB::Document
  
  property :created_at
  property :contents
  
  belongs_to :author
  belongs_to :post

end
