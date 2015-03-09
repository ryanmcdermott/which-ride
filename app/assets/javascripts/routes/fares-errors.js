App.FaresErrorsRoute = Ember.Route.extend({  
	renderTemplate: function () {
    this.render('fares-errors', {
    	into: 'application',
      outlet: 'main',
      controller: 'fares'
    });
  }
});