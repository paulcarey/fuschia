require 'rubygems'
require 'relaxdb'
require 'models'

RelaxDB.configure :host => "localhost", :port => 5984
RelaxDB.delete_db "lrug" rescue :ok
RelaxDB.use_db "lrug"

mal = User.new(:name => "mal").save!

alice = User.new(:name => "alice")
bob = User.new(:name => "bob", :best_friend => alice)
alice.best_friend = bob
RelaxDB.bulk_save(alice, bob)

p = Post.new(:contents => "I heart CouchDB", :author => alice).save!
p.comments << Comment.new(:contents => "first post", :author => bob)
p.comments << Comment.new(:contents => "nom nom nom", :author => mal)
p.save!

p = Post.new(:contents => "in ur couchdbz haxoring ur docs", :author => mal)
p.comments << Comment.new(:contents => "down with that sort of thing", :author => alice)
p.comments << Comment.new(:contents => "^^ +1", :author => bob)
p.save!

RelaxDB.db.put("/fuschia", File.read("fuschia.json"))
