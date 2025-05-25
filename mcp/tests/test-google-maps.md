# Google Maps MCP Server Test Cases - Austin Edition

This document contains test cases for verifying Google Maps MCP server functionality with Amazon Q CLI. Each test case targets a specific Maps API capability with an Austin, Texas focus.

## maps_geocode - Convert address to coordinates

```bash
q chat --no-interactive "What are the coordinates of the Texas State Capitol in Austin?"
```

Expected: Response should include precise latitude/longitude coordinates, formatted address, and place_id for the Texas State Capitol.

```bash
q chat --no-interactive "Convert the address of Barton Springs Pool in Austin to GPS coordinates"
```

Expected: Response should include the exact coordinates, formatted address, and place_id for Barton Springs Pool.

## maps_reverse_geocode - Convert coordinates to address

```bash
q chat --no-interactive "What address is located at coordinates 30.2672° N, 97.7431° W in Austin?"
```

Expected: Response should return a formatted address, place_id, and address components for this downtown Austin location.

```bash
q chat --no-interactive "Find the nearest street address to latitude 30.2849° N, longitude 97.7341° W in Austin"
```

Expected: Response should include a complete address with street, city, state, zip code, and address components.

## maps_search_places - Search for places using text query

```bash
q chat --no-interactive "Find coffee shops within 1000 meters of the University of Texas at Austin campus"
```

Expected: Response should list coffee shops near UT Austin with names, addresses, and locations.

```bash
q chat --no-interactive "What are the top-rated taco restaurants in South Congress, Austin?"
```

Expected: Response should include a list of taco restaurants in the South Congress area with names and addresses.

## maps_place_details - Get detailed information about a place

```bash
q chat --no-interactive "Tell me everything about Franklin Barbecue in Austin including hours, ratings, and contact information"
```

Expected: Response should include detailed information about Franklin Barbecue with name, address, contact info, ratings, reviews, and opening hours.

```bash
q chat --no-interactive "What are the operating hours, phone number, and customer reviews for Zilker Park in Austin?"
```

Expected: Response should include comprehensive details about Zilker Park with contact information, ratings, and opening hours.

## maps_distance_matrix - Calculate distances and times between points

```bash
q chat --no-interactive "How long would it take to drive from the Austin-Bergstrom International Airport to the Domain in Austin during rush hour?"
```

Expected: Response should include distance and estimated travel time by car between these two Austin locations.

```bash
q chat --no-interactive "Compare walking versus biking times from Lady Bird Lake to the Texas State Capitol"
```

Expected: Response should include distances and durations for both walking and biking between these Austin landmarks.

## maps_elevation - Get elevation data for locations

```bash
q chat --no-interactive "What is the elevation of Mount Bonnell in Austin?"
```

Expected: Response should include precise elevation data for Mount Bonnell.

```bash
q chat --no-interactive "Compare the elevations of Zilker Park and the University of Texas at Austin campus"
```

Expected: Response should include elevation data for both locations with a comparison.

## maps_directions - Get directions between points

```bash
q chat --no-interactive "Give me step-by-step driving directions from the Austin Central Library to Barton Springs Pool"
```

Expected: Response should include detailed route information with turn-by-turn directions, distance, and estimated duration.

```bash
q chat --no-interactive "What's the best public transit route from the Texas State Capitol to the Austin FC stadium?"
```

Expected: Response should include transit directions with bus/train routes, walking segments, transfers, distance, and duration.
