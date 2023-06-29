Strava::Web::Client.configure do |config|
  config.user_agent = 'Strava Ruby Client/1.0'
  config.ca_file = '/usr/lib/ssl/certs/certSIGN_ROOT_CA.pem'
  @ca_file="/usr/lib/ssl/cert.pem"
  @ca_path="/usr/lib/ssl/certs"
end

class GrabPolylines
  def client
    Strava::Api::Client.new(
      access_token: "9cc815bb251738d106d51d2c27c9c976ebc2dd71"
      # get by running strava-athlete-activities Token.refresh_existing_token
      # or check IKIreadme
    )
  end

  def get_photos
    page = 1
    per_page = 10
    activities = client.athlete_activities(page: page, per_page: per_page)
    activities.each do |a|
      next if a["total_photo_count"] == 0

      activity = client.activity(a.id)
      require'pry';binding.pry
      activity.photos.each do |p|
        photo_url = p["primary"]["urls"]["600"]
        Photo.create(url: photo_url)
      end
      require 'open-uri'
      open('image.png', 'wb') do |file|
        file << open('https://dgtzuqphqg23d.cloudfront.net/t-qtdh7oojntbbmFzDQO1IZZQTwhyy4jF6mcJrgSBs0-768x576.jpg').read
      end

      # create photo model

      end
    end
  end

  # GrabPolylines.new.get_photos
  

  def create_polylines
    existing_polyline_ids = Polyline.all.pluck(:activity_id)
    14.times do |page|
      next if page == 0
      puts "getting page:" 
      p page
      activities = client.athlete_activities(page: page, per_page: 100)
      puts "got #{activities.count} activities"
      return if activities.empty?

      activities.each do |activity|
        puts activity.id
        if activity == []
          return
        end
        next if existing_polyline_ids.include?(activity["id"])
        
        summary = activity["map"]["summary_polyline"]
        name = activity["name"]

        Polyline.create(
          activity_id: activity["id"],
          summary: summary,
          detail: name,
          activity_name: name,
          activity_started_at_date_time: activity["start_date_local"]
        )
      end
    end
  end

  # def get_activity_photos(activity_id)
  #   photos = client.activity_photos(activity_id)
  #   photos.each do |photo|
  #   end
  # end
end

# GrabPolylines.new.create_polylines
# client = GrabPolylines.new.client
# activity = client.activity(9152178688)
# photos = client.activity_photos(9152178688)

# polyline = r.json()["map"]["polyline"]

# get token

require "uri"
require "net/http"

url = URI("https://www.strava.com/oauth/token?client_id=63764&client_secret=2e6c5168e3b97a9c0975e5377041b8a416b4fbf8&refresh_token=932469c09ef3da9dbec99a9c8e8364b0f885b021&grant_type=refresh_token")

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Post.new(url)

response = https.request(request)
puts response.read_body