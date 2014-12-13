Divided Prototype
=======================

### What?

This is a very rough beginning of a game I'm working on with a friend. It's going to be a small mmo about something like the ebb and flow of natural forces in a world where political strength is drawn from nature... But we're still figuring it out. Also, the name is very subject to change but I needed a repo title :P

Because this is at least 50% a fun experiment, it's fairly unique in its architecture. These are the core facets:

* Designed for [Heroku](https://devcenter.heroku.com/articles/how-heroku-works)
  * 50 connections per dyno so as long as you have ~45 players or less at peak you can run it 100% free
  * Still entirely generalized so any server with Ruby (2.1.2 atm) and Thin installed should be able to run it fine
  * Nginx appears to be the go-to copilot
* [Phaser](http://phaser.io) for super easy desktop/mobile html5 gaming
* [Rails](http://rubyonrails.org/) for asset management now and flexibility/robustness for down the road
* [Faye](http://faye.jcoglan.com/architecture.html) for same-process persistent connections (thanks to @jamesotron for his excellent [faye-rails](https://github.com/jamesotron/faye-rails))
  * If you look in the git history I just built off of his faye-rails-example :P
* [Thin](http://code.macournoyer.com/thin/usage/)/[EventMachine](https://www.igvita.com/2008/05/27/ruby-eventmachine-the-speed-demon/) for evented awesomeness obviating the need for a background worker
* [Grape](https://github.com/intridea/grape/wiki) (eventually) for concise and dynamic hypermedia APIs (specifically, most likely, [HAL](http://haltalk.herokuapp.com/explorer/browser.html#/))
* [RSpec](http://www.rubydoc.info/gems/rspec-expectations/frames) for test love since all of the above test so nicely
  * Not sure about how well Faye will test, but pub/sub is fairly easy to fudge over in tests (so far, fudging over entirely)
  * Using [mock_em](https://github.com/rightscale/mock_em) to quickly test time-based scenarios

I previously tried working with puma/rails/redis rather than thin/rails/faye/eventmachine and it was a total shitshow trying to get a single dyno to do anything useful. You can peek around at my prior progress in a legacy branch if you want to make fun of me :P

But really, I've spent a lot of time and thought into finding just the right architecture for a pseudo-turn-based mmo that can, at least until it gets more popular than peaking at around 45 people, (read: not any time soon) run for free on a single dyno on heroku without sacrificing responsiveness or maintainability. By "pseudo-turn-based" I mean being a little creative with designing the game to not be 100% realtime so you have a little leniency on your architecture. Sure you -can- do full-duplex streaming with websockets using this stack, but you'd be pressed for cycles to do anything interesting with it to ~45 clients on a single thread while staying responsive without most of the high level benefits like proxy caching, standardized REST discoverability, etc. So by "pseudo-turn-based mmo" I mean "low expectations of action-reaction responsiveness in medium-sized multiplayer" since just a little bit of leeway lets us kick our shoes off and dip into the soothing simplicity of Ruby. :palm_tree:

In the long term my hope is that, either through this game or another, I'll eventually figure out or help someone figure out the ultimate seed that will grow into a beautiful community of interconnected player built and maintained mmos. Why pay a monthly fee when you could own your whole server/game for that cost or less?

### When?

Not anytime soon, but I'm working on it :P We're currently very early in the design process and are just toying around with mechanics.

### Where?

The current, (mostly) stable state of the game will typically be running on [this heroku server](http://divided.herokuapp.com/)

### How?

To run locally, use `bundle exec thin start -R config.ru`. Beware that this will not work in rackup development mode, see [this issue](https://github.com/faye/faye/issues/25) for details.

It should be immediately deployable:

```sh
$ git clone https://github.com/jcwilk/divided.git
$ cd divided
$ heroku create app-name-goes-here
```

Voila, then after the heroku deploy spam it should be accessible at http://app-name-goes-here.herokuapp.com/ or whatever better name you chose. No plugins required (yet, at least).


Feel free to ask questions or provide criticisms! (unless it's refactoring/cleanup/testing suggestions... stuff is in full retard mode until the design dust settles a bit, sorry! After that I'll eat them up :P)

### Who?

Just us chickens. If you want to take part, probaby don't bother yet as saying it was still under heavy construction would be generous, but definitely do contact me via email (jcwilkatgmaildotcom) and let me know if you have interest! Once things are a bit more settled though it'll be the same pull request dealio as anything else.

### License

MIT
