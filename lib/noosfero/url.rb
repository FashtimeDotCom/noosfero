require 'noosfero'

# This module defines utility methods for generating URL's in contexts where
# one does not have a request (i.e. ActionMailer classes like TaskMailer).
#
# TODO: document the use of config/web.yml in a INSTALL document
module Noosfero::URL

  include ActionController::UrlWriter

  class << self

    def config
      if @config.nil?
        config_file = File.join(RAILS_ROOT, 'config', 'web.yml')
        if File.exists?(config_file)
          @config = YAML::load_file(config_file)
        else
          if ENV['RAILS_ENV'] == 'production'
            @config = {
            }
          else
            @config = {
              'path' => '',
              'port' => 3000
            }
          end
        end
      end

      @config
    end

    def included(other_module)
      other_module.send(:include, ActionController::UrlWriter)
    end

  end

  def port
    Noosfero::URL.config['port']
  end

  def path
    Noosfero::URL.config['path']
  end

  def generate_url(options)
    local_options = {}
    local_options[:port] = self.port unless self.port.nil?

    url = url_for(local_options.merge(options))

    if self.path.blank?
      url
    else
      url.sub(/(http:\/\/[^\/]+(:\d+)?)\//, "\\1#{self.path}/")
    end
  end


end