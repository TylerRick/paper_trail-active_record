#ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
#ActiveRecord::Base.logger = Logger.new(STDOUT)

$db = ENV["DB"].presence || "sqlite3"
config = YAML.load_file(File.expand_path('../../database.yml', __FILE__))[$db]
ActiveRecord::Base.establish_connection config

