# README

since Mark last worked on this:

added the controller and view to render things currently visible at `/`

I'd like to add leaflet map, like https://github.com/josh-works/strava_run_polylines_osm/blob/main/templates/leaflet.html#L6-L49

Done, sorta working. I can hardcode a polyline in the javascript directly, and get it to render on the map "in rails". 

I then had a bear of a time passing a polyline from the controller, to the front end, so it could be referenced inside a javascript front-end.

Tried data-attributes, ended up with the 'gon' gem. So, I'm passing (now) an encoded string that is _almost_ a good, usable polyline.

```
[&quot;summary_o_cqFheu_SKDKGK?GG[DWCIEM@OASDMAMEKBKGe@L[IGF@@ACBA?BUDEVEBALA`@Fh@Ax@ANCDEXARDR`@GCB@AC?EBKHCF?TMCMLCE?ML?AHHG@FGF?CG\\FK@BEGKF@KBAGKECGU@MBABBKJ@K@A?FEF@??DAK@B?CFCCD@EACGBB@?ADTAA@QFKT?PG?CHF?CD@?D?GQOUACO?KDGFAF@@EJCOcAFQ?MDOC_@CE@OEQ?CF?@CEEBEf@BFCRD
```

that leading `&quot;` bit is the trouble.

I could also encode it differently in the controller....

like _maybe_ `Polyline.all.pluck(:summary).to_json`

OK, I ended up plopping `html_safe` to the end, and it working:

```
Polyline.all.pluck(:summary).to_json.html_safe
```

and we now get, in the console:

```
["summary_o_cqFheu_SKDKGK?GG[DWCIEM@OASDMAMEKBKGe@L[IGF@@ACBA?BUDEVEBALA`@Fh@Ax@ANCDEXARDR`@GCB@AC?EBKHCF?TMCMLCE?ML?AHHG@FGF?CG\\FK@BEGKF@KBAGKECGU@MBABBKJ@K@A?FEF@??DAK@B?CFCCD@EACGBB@?ADTAA@QFKT?PG?CHF?CD@?D?GQOUACO?KDGFAF@@EJCOcAFQ?MDOC_@CE@OEQ?CF?@CEEBEf@BFCRD
```

Now seeing 

```
Uncaught Error: Invalid LatLng object: (0.00014, NaN)
```

oh, right, the polylines, the first ones, were fake, I added them via the rails console a while ago. Let's delete those from the db:

```
Polyline.first
_.destroy
```

reload the page... still broken, but I still think that was needed. Feels like I'm over-burdening the Leaflet API or Mapbox or something, with all my page refreshes.

Let's remove some stuff from the page and inspect the polylines. I smell an encoding problem.

When I remove the map modification js, and `console.log` each iteration, turns out the arrays are getting split into every single character. 🙄

added some `JSON.parse(window.polylines)` magic, and good to go:

```javascript
     <script>
      window.polylines = "<%= j @polylines %>"

      var map = L.map('map').setView([ 39.730133, -105.085322 ], 13);
      L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
        attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
        maxZoom: 22,
        minZoom: 1,
        id: 'mapbox/satellite-v9',
        tileSize: 512,
        zoomOffset: -1,
        accessToken: 'pk.eyJ1Ijoiam9zaHdvcmtzIiwiYSI6ImNrcWk2NzUxeTJhbm8yem4weDFreTY5bjQifQ.Qja1F9B1-i7hK3KOvSYAvg'
      }).addTo(map);
      var decoded = JSON.parse(window.polylines)

        for (let run of decoded) {
          var coordinates = L.Polyline.fromEncoded(run).getLatLngs();
          L.polyline(
            coordinates,
            {
                color: '#00FF00',
                weight: 2,
                opacity: .7,
                lineJoin: 'round'
            }
        ).addTo(map);
        }
     </script>
```

There's the whole thing. `git commit`. Then need to think on what's next. This is the thing that stopped me last time. :facepalm: 

I'm pretty satisfied, and looking at this data from just the last 30 days. or, rather, the last 30 activities. who knows what 30 days of activity would look like. I could figure that out, though.

I'll modify the script to include the activity date and time

I'll re-run it to get the last 30 activities. 

I'll add a slider or date picker or something so the front-end can adjust the time-range that the back-end is sending. 

or make the full objects available to the front end. 

This is cool. 

I think a part 2 will soon be to get multiple pages of results back from the strava API. But I'd rather figure out how to filter the routes by recency, THEN do multiple pages of activities. The full like four years of data is pretty overwhelming. 

```ruby
# wrote a migration to add `started_at:date` 

Polyline.all.each do |p|
  p.update(started_at: (1.10).days.ago)
end

Polyline.all.sort_by(&:started_at).pluck(:id)

```

that gives me something nominally sortable, i'll assume this is good, not going to re-query the API just yet. 

I'll sort some of these in the controller next. 
[...]

OK, filtering a bit, having trouble with the timestamp thing I'm trying to use, I don't really like it. battery is about to die, progress was made, good enough.






----------------

detour, need to re-gain strava password. My little rails app that had saved a token/refresh_token got the DB replaced by this new app, so I need to rebuild the postman script or something. I'm gonna run it then save it in the rails app. 


Got it. Used Postman to hit

`https://www.strava.com/oauth/token?client_id=123456&client_secret=foo&refresh_token=bar&grant_type=refresh_token`

and got a new `access_code` in response. 

[another hour or so of work]


I:

1. got the token working
2. Ran new migrations to convert the column on the table to `datetime`, which is much more flexible
3. re-queried strava to save accurate starting timestamp data to the local DB
4. added filters in controller to show data between certain date ranges
5. changed color filter so all trip segments are colored differently

`git ac -m "randomize colors, filter runs by date"`

-----------------------

OK, now I want a button to jump the view to a certain city and zoom level.

`[Seattle][Bali][Trip to Canada]`

each button could have `latlng=39.681635,-105.040421,12` and could split on commas, something like `lat, lng, zzoom`

Got it working, btw. Buttons add the query params to the URL, I can read those in the javascript, set the map coords to whatever's in the browser bar

--------------------

Now I'm trying to get the call to the Strava API to auto-paginate, so I can push it to production, and load the data once, and have stuff 'live' for the world. 

I'll need to be able to jump into a rails console session, and run `GrabPolylines.new.create_polylines`, and have the DB populate, and then have it all viewable in a browser, mobile or phone. 

:fingerscrossed:

Should be something like:

```ruby
def create_polylines
  page = 1
  loop do
    client.athlete_activities(page: page, result_count: 100).each do |activity|
      # This doesn't get hit if I over-shoot the page range
    end

    page +=1 
    return if client.athlete_activities(page: page, result_count: 100).response.empty?
    end
end
```

-------------------

Got it. Very janky. 

```ruby
14.times do |page|
  next if page == 0
  client.athlete_activities(page:page).each do |activity|
  end
end
```

it's beautiful, in that it'll run in production.

- [ ] get this app deployed on heroku (non-trivial, but discrete)
- [ ] run script to load my data in production, so all visitors of the heroku app see my strava activity data
- [ ] add /show page to scope lat/long to a polyline segment

i want to then want to email three possible companies/people about job things, and say "i'm building this in public to scratch some software itch".

## Let's get app running in prod, first

this requires swapping sqlite to postgres.

I'll run `rails db:migrate` locally and garden it towards wordking.

Swapped `pg` gem, instead of `sqlite`. next time I'm gonna initialize w/postgres.

ran `rails db:migrate` got `connection refused` on port `5432`, no server accepting tcp/ip connections.

starting/updating postgres app....

Hah. Easy. Stack Overflow FTW.

https://stackoverflow.com/a/54319956

`bin/rails db:system:change --to=postgresql`

Now back to making sure Postgres is running locally... I seem to have two different instances of this. 

Boom, it works. Re-ran `rails db:setup`. 

restarted server, rendering my polylines from a fixed seeds.rb file (added a `,`)

Importing from Strava (`rails c`, `GrabPolylines.new.create_polylines`) erroring with:

```
9185739268 is out of range for ActiveModel::Type::Integer with limit 4 bytes (ActiveModel::RangeError)
```

```
$ heroku config --app mobility-data

=== mobility-data Config Vars
LANG:                     en_US.UTF-8
RACK_ENV:                 production
RAILS_ENV:                production
RAILS_LOG_TO_STDOUT:      enabled
RAILS_SERVE_STATIC_FILES: enabled
SECRET_KEY_BASE:          alsdkjfa;lskdjflaksjd


$ heroku addons:create heroku-postgresql
# https://stackoverflow.com/questions/32815705/heroku-pgconnectionbad-could-not-connect-to-server-connection-refused

$ heroku config --app mobility-data
=== mobility-data Config Vars
DATABASE_URL:             postgres://hpaasldkfj4@ec2-54-145-174-66.compute-1.amazonaws.com:5432/dcasdfd
LANG:                     en_US.UTF-8
RACK_ENV:                 production
RAILS_ENV:                production
RAILS_LOG_TO_STDOUT:      enabled
RAILS_SERVE_STATIC_FILES: enabled
SECRET_KEY_BASE:          asdf
```

thought that would do it but it's not...

```
PG::ConnectionBad: connection to server at "54.145.174.66", port 5432 failed: FATAL:  permission denied for database "postgres"
DETAIL:  User does not have CONNECT privilege.
```

OK, got it working. Don't know what the problem was. Restarted heroku, learned I could only really do `heroku pg:reset`, which helped.

Now I'm trying to run `GrabPolylines.new.create_polylines` from a heroku rails console. It's generating an error as soon as it tries to hit the Strava API:

```
> heroku run rails c
Running rails c on ⬢ mobility-data... up, run.8528 (Eco)
Loading production environment (Rails 7.0.5)
irb(main):001:0> GrabPolylines.new.create_polylines
getting page:
1
/app/vendor/ruby-3.1.2/lib/ruby/3.1.0/net/http.rb:1040:in `initialize': SSL_CTX_load_verify_file: system lib (Faraday::SSLError)
/app/vendor/ruby-3.1.2/lib/ruby/3.1.0/net/http.rb:1040:in `initialize': SSL_CTX_load_verify_file: system lib (OpenSSL::SSL::SSLError)
irb(main):002:0>
```


