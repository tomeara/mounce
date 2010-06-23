require 'rubygems'
require 'rbosa'
require 'scrobbler'

class Mounce
  attr_reader :artist, :track

  def initialize(config_file='~/.mounce.yml')
      config(File.expand_path(config_file))
      @itunes = OSA.app('iTunes')
    if @config[:lastfm_user].nil?
      @artist, @track = find_song_information
    else
      @lastfm_user = Scrobbler::User.new(@config[:lastfm_user])
      @artist = @lastfm_user.recent_tracks.first.artist
      @track = @lastfm_user.recent_tracks.first.name
    end
  end

  def message(tag='#music')
    if @config[:lastfm_user].nil?
      text = [@artist, @track].compact.join(' - ')
      "#{tag} #{text}"
    else
      "#{tag} #{@artist} - #{@track}"
    end
  end

  def share!
    `curl #{@config['api']} -u #{@config['username']}:#{@config['password']} -d status="#{message}" -d source="mounce"`
  end

  private

    def config(config_file)
      raise "Missing config file: #{config_file} (see 'mounce --help')" unless File.exist?(config_file)
      @config = YAML.load(open(config_file))['presently']
    end

    def find_song_information
      return @itunes.current_stream_title.split('-').map{|item| item.strip} if stream?
      [@itunes.current_track.artist, @itunes.current_track.name]
    end

    def stream?
      @itunes.current_stream_title
    end
end

