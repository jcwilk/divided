Divided Prototype
=======================

### What?

This is a very rough beginning of a game I'm working on with a friend. It's going to be a small mmo about something like the ebb and flow of natural forces in a world where political strength is drawn from nature... But we're still figuring it out. Also, the name is very subject to change but I needed a repo title :P

Because this is at least 50% a fun experiment, it's fairly unique in its architecture. These are the core facets:

* [Phaser](http://phaser.io) for super easy desktop/mobile html5 gaming
* Rails for asset management now and flexibility/robustness for down the road
* Faye for same-process persistent connections (thanks to @jamesotron for his excellent [faye-rails](https://github.com/jamesotron/faye-rails))
  * If you look in the git history I just built off of his faye-rails-example :P
* Thin/EventMachine for concurrent evented awesomeness obviating the need for a background worker
* Grape (eventually) for concise and dynamic hypermedia APIs (specifically, most likely, HAL)
* rSpec for test love (soon, still experimenting) since all of the above test so nicely
  * Not sure about how well Faye will test, but pub/sub is fairly easy to fudge over in tests

I previously tried working with puma/rails/redis rather than thin/rails/faye/eventmachine and it was a total shitshow trying to get a single dyno to do anything useful. You can peek around at my prior progress in a legacy branch if you want to make fun of me :P

But really, I've spent a -lot- of time and thought into coming up with just the right architecture for a pseudo-turn-based mmo that can, at least until it gets more popular than peaking at around 45 people, (read: not any time soon) run for free on a single dyno on heroku, and very responsively. My hope is that, either through this game or another, I'll eventually figure out or help someone figure out the ultimate seed that will grow into a beautiful community of interconnected player built and maintained mmos.

Why pay a monthly fee when you could own your whole server/game for that cost or less?

### When?

Not anytime soon, but I'm working on it :P We're currently very early in the design process and are just toying around with mechanics.

### Where?

The current, (mostly) stable state of the game will typically be running on [this heroku server](http://divided.herokuapp.com/)

### How?

To run locally, use `bundle exec thin start -R config.ru`. Beware that this will not work in rackup development mode, see [this issue](https://github.com/faye/faye/issues/25) for details.

It should be immediately deployable, just do a `heroku create` and shove it on up there with a `git push heroku master` (or `branchname:master` instead of `master` if you're working under a different branch... But you know that.)

Feel free to ask questions or provide criticisms! (unless it's refactoring/cleanup/testing suggestions... stuff is in full retard mode until the design dust settles a bit, sorry! After that I'll eat them up :P)

### Who?

Just us chickens. If you want to take part, probaby don't bother yet as saying it was still under heavy construction would be generous, but please do let me know if you have interest! Eventually it'll be the same pull reuqest dealio as anything else, hopefully.

### License

MIT
