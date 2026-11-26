#!/usr/bin/env python3
"""Show addresses on an interactive map in the browser.

Usage: python show_addresses_on_map.py addresses.txt
       python show_addresses_on_map.py addresses.txt --mode route
"""

import argparse
import json
import sys
import tempfile
import webbrowser
from urllib.parse import quote


def read_addresses(filepath):
    with open(filepath) as f:
        return [line.strip() for line in f if line.strip()]


def open_as_route(addresses):
    """Open all addresses as waypoints on a Google Maps route."""
    parts = "/".join(quote(addr) for addr in addresses)
    url = f"https://www.google.com/maps/dir/{parts}"
    print(f"Opening {len(addresses)} addresses as a route...")
    webbrowser.open(url)


def open_as_pins(addresses):
    """Show all addresses as markers on a single interactive map."""
    html = _build_map_html(addresses)
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
        f.write(html)
    print(f"Opening {len(addresses)} addresses on a single map...")
    webbrowser.open("file://" + f.name)


def _build_map_html(addresses):
    addresses_json = json.dumps(addresses)
    return f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Addresses Map</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9/dist/leaflet.js"></script>
<style>
  body {{ margin: 0; }}
  #map {{ height: 100vh; width: 100%; }}
  #status {{
    position: fixed; top: 10px; left: 60px; z-index: 1000;
    background: white; padding: 6px 12px; border-radius: 6px;
    box-shadow: 0 2px 6px rgba(0,0,0,.3); font: 14px sans-serif;
  }}
</style>
</head>
<body>
<div id="map"></div>
<div id="status">Geocoding addresses...</div>
<script>
const addresses = {addresses_json};
const map = L.map('map').setView([31.5, 34.75], 8);
L.tileLayer('https://{{s}}.tile.openstreetmap.org/{{z}}/{{x}}/{{y}}.png', {{
  attribution: '&copy; OpenStreetMap contributors'
}}).addTo(map);

const bounds = [];
let done = 0;
const status = document.getElementById('status');

function geocode(addr, idx) {{
  const url = 'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + encodeURIComponent(addr);
  return fetch(url)
    .then(r => r.json())
    .then(data => {{
      if (data.length > 0) {{
        const lat = parseFloat(data[0].lat);
        const lon = parseFloat(data[0].lon);
        const gmapsUrl = 'https://www.google.com/maps/search/?api=1&query=' + encodeURIComponent(lat + ',' + lon);
        const marker = L.marker([lat, lon]).addTo(map);
        marker.bindPopup('<b>' + (idx + 1) + '.</b> ' + addr + '<br><a href="' + gmapsUrl + '" target="_blank">Open in Google Maps</a>');
        marker.on('click', () => window.open(gmapsUrl, '_blank'));
        bounds.push([lat, lon]);
      }} else {{
        console.warn('Could not geocode:', addr);
      }}
    }})
    .catch(err => console.error('Geocode error for', addr, err))
    .finally(() => {{
      done++;
      status.textContent = 'Geocoded ' + done + ' / ' + addresses.length;
      if (done === addresses.length) {{
        if (bounds.length > 0) map.fitBounds(bounds, {{ padding: [40, 40] }});
        status.textContent = bounds.length + ' / ' + addresses.length + ' addresses shown';
        setTimeout(() => status.style.display = 'none', 4000);
      }}
    }});
}}

// Nominatim asks for max 1 req/s; stagger requests by 1.1s each.
addresses.forEach((addr, i) => {{
  setTimeout(() => geocode(addr, i), i * 1100);
}});
</script>
</body>
</html>"""


def main():
    parser = argparse.ArgumentParser(description="Show addresses on Google Maps")
    parser.add_argument("file", help="Text file with one address per line")
    parser.add_argument(
        "--mode",
        choices=["route", "search"],
        default="search",
        help="'route' shows all on one map as waypoints in Google Maps, "
             "'search' shows all addresses as pins on a single interactive map",
    )
    args = parser.parse_args()

    addresses = read_addresses(args.file)
    if not addresses:
        print("No addresses found in file.", file=sys.stderr)
        sys.exit(1)

    print(f"Found {len(addresses)} addresses:")
    for i, addr in enumerate(addresses, 1):
        print(f"  {i}. {addr}")

    if args.mode == "route":
        open_as_route(addresses)
    else:
        open_as_pins(addresses)


if __name__ == "__main__":
    main()
