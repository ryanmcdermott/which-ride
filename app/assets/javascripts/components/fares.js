App.FaresFormComponent = Ember.Component.extend({
  actions: {
    submit: function() {
      this.sendAction('submit', {
        origin: this.get('origin'),
        destination: this.get('destination')
      });
    }
  }
});