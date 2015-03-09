App.FaresResultsRoute = Ember.Route.extend({
	model: function () {
		return this.store.all('fare');
	},

  afterModel: function (fare, transition) {
    if (fare.get('length') < 1) {
      this.transitionTo('fares');
    }
  },
  
	renderTemplate: function() {
    this.render('fares-results', {
    	into: 'application',
      outlet: 'main',
      controller: 'fares-results'
    });
  }
});