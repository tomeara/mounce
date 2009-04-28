require 'rubygems'
require 'rbosa'

class Mounce
  attr_reader :artist, :track

  def initialize(config_file='~/.mounce.yml')
    config(File.expand_path(config_file))
    @itunes = OSA.app('iTunes')
    @artist, @track = find_song_information
  end

  def message(tag='#music')
    text = [@artist, @track].compact.join(' - ')
    "#{tag} #{text}"
  end

  def share!
    `curl #{@config['api']} -u #{@config['username']}:#{@config['password']} -d status="#{message}"`
  end

  private

    def config(config_file)
      if File.exist?(config_file)
        @config = YAML.load(open(config_file))['presently']
      else
        raise "Missing config file: ~/.mounce.yml (see 'mounce --help')"
      end
    end

    def find_song_information
      return @itunes.current_stream_title.split('-').map{|item| item.strip} if stream?
      [@itunes.current_track.artist, @itunes.current_track.name]
    end

    def stream?
      !!@itunes.current_stream_title
    end
end
