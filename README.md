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


heroku certs:update

----------

woof burnt another 90 minutes on this.

I think it's related to where certs are stored.

I can do `heroku run bash` and peek at `/usr/lib/ssl/certs/ca-certificates.crt`, and there's certs there. 

When I create a client, I see:

```ruby
client = Strava::Api::Client.new(
     access_token: "2de9ce57234f2846c271369577cca95def2baf39"
   # get by running strava-athlete-activities Token.refresh_existing_token
   # or check IKIreadme
)
=>
#<Strava::Api::Client:0x00007ff64a2f8b70
...
client
=>
#<Strava::Api::Client:0x00007ff64a2f8b70
 @access_token="2de9ce57234f2846c271369577cca95def2baf39",
 @ca_file="/usr/lib/ssl/cert.pem",
 @ca_path="/usr/lib/ssl/certs",
 @endpoint="https://www.strava.com/api/v3",
 @logger=
```

which seems okay, except I cannot write the `cert.pem` file via 

```
~ $ curl -fsSL curl.haxx.se/ca/cacert.pem -o "/usr/lib/ssl/cert.pem"
curl: (23) Failure writing output to destination
```

or 

```
curl -fsSL curl.haxx.se/ca/cacert.pem -o "$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')"
```

OK, the fix was to find _where_ on the filesystem the `ca_file` lived. 

I then set a configuration option to source that `ca_file`:

```ruby
Strava::Web::Client.configure do |config|
  config.user_agent = 'Strava Ruby Client/1.0'
  config.ca_file = '/usr/lib/ssl/certs/certSIGN_ROOT_CA.pem'
end

class GrabPolylines
  def client
    Strava::Api::Client.new(
      #
```

The way to find which file I should use was... a way.

First, I found a script to download a 'good'  `ca` file. `ca` is `certificate authority` and it's a bunch of cryptographic keys in a glorified text file.  

It looks like this:

```
##
## Bundle of CA Root Certificates
##
## Certificate data from Mozilla as of: Tue May 30 03:12:04 2023 GMT
##
## This is a bundle of X.509 certificates of public Certificate Authorities
## (CA). These were automatically extracted from Mozilla's root certificates
## file (certdata.txt).  This file can be found in the mozilla source tree:
## https://hg.mozilla.org/releases/mozilla-release/raw-file/default/security/nss/lib/ckfw/builtins/certdata.txt
##
## It contains the certificates in PEM format and therefore
## can be directly used with curl / libcurl / php_curl, or with
## an Apache+mod_ssl webserver for SSL client authentication.
## Just configure this file as the SSLCACertificateFile.
##
## Conversion done with mk-ca-bundle.pl version 1.29.
## SHA256: c47475103fb05bb562bbadff0d1e72346b03236154e1448a6ca191b740f83507
##


GlobalSign Root CA
==================
-----BEGIN CERTIFICATE-----
MIIDdTCCAl2gAwIBAgILBAAAAAABFUtaw5QwDQYJKoZIhvcNAQEFBQAwVzELMAkGA1UEBhMCQkUx
GTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkds
b2JhbFNpZ24gUm9vdCBDQTAeFw05ODA5MDExMjAwMDBaFw0yODAxMjgxMjAwMDBaMFcxCzAJBgNV
BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYD
VQQDExJHbG9iYWxTaWduIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDa
DuaZjc6j40+Kfvvxi4Mla+pIH/EqsLmVEQS98GPR4mdmzxzdzxtIK+6NiY6arymAZavpxy0Sy6sc
:
## This is a bundle of X.509 certificates of public Certificate Authorities
## (CA). These were automatically extracted from Mozilla's root certificates
## file (certdata.txt).  This file can be found in the mozilla source tree:
## https://hg.mozilla.org/releases/mozilla-release/raw-file/default/security/nss/lib/ckfw/builtins/certdata.txt
##
## It contains the certificates in PEM format and therefore
## can be directly used with curl / libcurl / php_curl, or with
## an Apache+mod_ssl webserver for SSL client authentication.
## Just configure this file as the SSLCACertificateFile.
##
## Conversion done with mk-ca-bundle.pl version 1.29.
## SHA256: c47475103fb05bb562bbadff0d1e72346b03236154e1448a6ca191b740f83507
##


GlobalSign Root CA
==================
-----BEGIN CERTIFICATE-----
MIIDdTCCAl2gAwIBAgILBAAAAAABFUtaw5QwDQYJKoZIhvcNAQEFBQAwVzELMAkGA1UEBhMCQkUx
GTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkds
b2JhbFNpZ24gUm9vdCBDQTAeFw05ODA5MDExMjAwMDBaFw0yODAxMjgxMjAwMDBaMFcxCzAJBgNV
BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYD
VQQDExJHbG9iYWxTaWduIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDa
DuaZjc6j40+Kfvvxi4Mla+pIH/EqsLmVEQS98GPR4mdmzxzdzxtIK+6NiY6arymAZavpxy0Sy6sc
THAHoT0KMM0VjU/43dSMUBUc71DuxC73/OlS8pF94G3VNTCOXkNz8kHp1Wrjsok6Vjk4bwY8iGlb
Kk3Fp1S4bInMm/k8yuX9ifUSPJJ4ltbcdG6TRGHRjcdGsnUOhugZitVtbNV4FpWi6cgKOOvyJBNP
c1STE4U6G7weNLWLBYy5d4ux2x8gkasJU26Qzns3dLlwR5EiUWMWea6xrkEmCMgZK9FGqkjWZCrX
gzT/LCrBbBlDSgeF59N89iFo7+ryUp9/k5DPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0BAQUF
AAOCAQEA1nPnfE920I2/7LqivjTFKDK1fPxsnCwrvQmeU79rXqoRSLblCKOzyj1hTdNGCbM+w6Dj
Y1Ub8rrvrTnhQ7k4o+YviiY776BQVvnGCv04zcQLcFGUl5gE38NflNUVyRRBnMRddWQVDf9VMOyG
j/8N7yy5Y0b2qvzfvGn9LhJIZJrglfCm7ymPAbEVtQwdpf5pLGkkeB6zpxxxYu7KyJesF12KwvhH
hm4qxFYxldBniYUr+WymXUadDKqC5JlR3XC321Y9YeRq4VzW9v493kHMB65jUr9TU/Qr6cf9tveC
X4XSQRjbgbMEHMUfpIBvFSDJ3gyICh3WZlXi/EjJKSZp4A==
-----END CERTIFICATE-----

Entrust.net Premium 2048 Secure Server CA
=========================================
-----BEGIN CERTIFICATE-----
MIIEKjCCAxKgAwIBAgIEOGPe+DANBgkqhkiG9w0BAQUFADCBtDEUMBIGA1UEChMLRW50cnVzdC5u
```

```
curl -fsSL curl.haxx.se/ca/cacert.pem -o "$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')"
```

the file couldn't be written. When I ran `OpenSSL::X509::DEFAULT_CERT_FILE` in a rails console, I got a file path and expected file, but when I logged into heroku's file system with `heroku run bash`, and looked for that file, I couldn't find it. 

I DID find `/usr/lib/ssl/certs/certSIGN_ROOT_CA.pem`, which looked like the certificate file. The file itself looked close in content to what I expected, and the internet sleuthing I'd done talked about updating Faraday or SSL Connection parameters to specifcy a certificate authority file. 

I looked in the `strava ruby client` docs and found a param called `ca_file`, and learned that I could initialize a client with a non-default ca file path. That's what I did. Re-pushed the code to Heroku, and I was able to make the Strava API calls with correct SSL certs. 

---------------


So, the above debugging soaked up two work sessions. Here's how the checklist stands:

- [x] get this app deployed on heroku (non-trivial, but discrete)
- [x] run script to load my data in production, so all visitors of the heroku app see my strava activity data
- [ ] add /show page to scope lat/long to a polyline segment

i want to then want to email three possible companies/people about job things, and say "i'm building this in public to scratch some software itch".

Let's add the `/show` page next, that'll satisfy shirley's questions about 'what is the point for which you're building this'.

The app is struggling super hard on my phone to pan and zoom the map. Adding `running notes at bottom of file`. 

---------------

i finished the `/show` page. Added a TIL around routes, `/activity/show` vs `/activity/:id`. 

I've now _rapidly_ created the `/show` page with a working map, it auto-centers on the starting coordinates of the polyline. I moved _way_ fast through passing a JSON-encoded, html_safe string from the controller, and using the `j` gem to set `window.polyline`, then in the javascript, did `var encoded_polyline = `, then `var polyline = JSON.decode(encoded_polyline)`, etc. 

Popped `map.setView(coordinates[0])` right before `</script>` on the show, and good to go.

I'd now like to make some minor navigational tweaks - on `/show` give a `back to index`, and on the `/index`, add a table of the rendered polylines, with each having a link to it's respective `show` page. 

Not bad for what was about 20 minutes of well-documented, methodical work.

[...]

Done, added the table and back buttons. Had to re-jigger how I was building/passing around the `@polylines` object. I'd had it as, in the controller, something like `polylines.pluck[:detail]`, so was getting an array of `["asdf", "asdfa"]` in the view. I'm now passing through the full Polyline objects, `[{id: "1", detail: "abc"}, {}, {}]`, and had to update the view to accommodate.

I then popped in a table with a little more info about each polyline, and it's starting to look like a thing!


# Running Notes for Bottom Of File

## issues

- [ ] pinch and zoom and drag is broken on mobile, causes page reloads unintentionally

## features

- [ ] make `GrabPolylines.rb` smart about getting new `access_code` if needed
- [ ] modify script to stop running if route ID has been found
- [ ] `show` page for `polyline` that shows just that polyline, or the start of it with a set zoom
- [ ] add javascript function that changes lat/long/zoom in URL every few seconds based on map movements