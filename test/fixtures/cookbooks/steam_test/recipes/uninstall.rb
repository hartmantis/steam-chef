# Encoding: UTF-8

include_recipe 'steam'

steam_app 'default' do
  action :remove
end
