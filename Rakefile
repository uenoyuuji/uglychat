require './route.rb'

task :console do
  system('bundle exec irb -r ./route.rb')
end

task('db:migrate') do
  rack_env = ENV['RACK_ENV'] || 'development'
  system("bundle exec ridgepole -c ./environment/#{rack_env}/mysql.yml -E writable --apply -f db/Schemafile")
end
