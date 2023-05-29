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
      decoded = JSON.parse(window.polylines)
        console.log(decoded)
        for (let run of decoded) {
          console.log(run)
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