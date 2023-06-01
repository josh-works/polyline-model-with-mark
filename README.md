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