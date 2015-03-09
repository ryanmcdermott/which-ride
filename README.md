# Which Ride

----
## What is it?


Which Ride is an Uber and Lyft price comparison app written in Ruby on Rails and Ember.js.


----
## Installation
1. [Install Vagrant](http://www.vagrantup.com/downloads)
2. `git clone https://github.com/ryanmcdermott/which-ride.git` 
3. `vagrant up` (grab a coffee, this may take a while)
4. On your host machine, open up a tab in your favorite browser and go to [http://localhost:8080](http://localhost:8080)
5. (Optional) Run `rake fares:lyft` to get new Lyft fares


----
## Usage
1. Subsequent to installation, when starting up the app from when the VM is halted, cd to the directory on your host machine
2. `vagrant up`
3. `vagrant ssh`
4. `cd /vagrant`
5. `rvm gemset use which-ride`
6. `rails s`

----
## TODO
* Delete models on index page to prevent duplicate or previous fares from appearing in the /fares
* When Uber's public API fails, use cached Uber fares as provided by `rake fares:uber`

----
## Contributing
Pull requests are much appreciated and accepted.


----
## License
Which Ride is released under the [MIT License] (http://www.opensource.org/licenses/MIT)

----
## 
[which-ride](http://whichride.herokuapp.com/)