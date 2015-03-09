App.FaresRoute = Ember.Route.extend({
  events: {
    loadingState: function () {
      this.render('loading', { 
        into: 'application',
        outlet: 'main'
      });
    }
  }
});