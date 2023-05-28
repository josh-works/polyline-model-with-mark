class GrabPolylines

  def client
    Strava::Api::Client.new(
      access_token: "a5b2dffabf1b5cd09c6c450af58f1b77c44f13c0"
      # get by running strava-athlete-activities Token.refresh_existing_token
    )
  end

  def create_polylines
    existing_polylines = Polyline.all.pluck(:summary)

    client.athlete_activities.each do |activity|
      summary = activity["map"]["summary_polyline"]
      name = activity["name"]
      next if existing_polylines.include?(summary)

      Polyline.create(
        summary: summary,
        detail: name,
        activity_name: name
      )
      
    end
  end

  def get_activity_photos(activity_id)
    photos = client.activity_photos(activity_id)
    photos.each do |photo|

    end
  end
end

# GrabPolylines.new.create_polylines
# client = GrabPolylines.new.client
# activity = client.activity(9152178688)
# photos = client.activity_photos(9152178688)

# polyline = r.json()["map"]["polyline"]

