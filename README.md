# blaseball-scorecard

A ruby script that draws a scorecard for a game of Blaseball (http://blaseball.com).

Thanks to SIBR and [Blaseball Reference](https://blaseball-reference.com/) for collecting and
hosting the data and making APIs available.

## Requirements
`ruby-2.6.6`, plus a few standard gems: `httparty`, `rspec`, 'bundler'

Uses the `ruby2d` gem to draw graphics.

## Usage
`bundle install` to install dependencies.

`./scorecard.rb game-id` where `game-id` is a [SIBR Reblaze](http://reblase.sibr.dev) game ID. This
will pull data from Datablase and Chronicler and (for the purposes of development) dump it into two
files named `chr-game-updates-uuid.json` and `chr-game-lineups-uuid.json`.

You can then reload those files with `./scorecard.rb chr-game-updates-(game-id).json` (the `lineups`
filename is inferred).

Press Escape to close the scorecard window after it renders.
