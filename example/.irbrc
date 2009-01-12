require 'rubygems'
require 'relaxdb'
require 'models'

RelaxDB::UuidGenerator.id_length = 4
RelaxDB.configure :host => "localhost", :port => 5984, :logger => Logger.new(STDOUT)
RelaxDB.use_db "lrug"

require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = ".irb_history"

IRB.conf[:PROMPT_MODE] = :SIMPLE
