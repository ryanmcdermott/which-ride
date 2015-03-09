App.FaresController = Ember.ObjectController.extend({
	actions: {
    getFare: function (fare) {
    	var that = this;
      var origin = $('#origin');
      var destination = $('#destination');
      
      var fareRequest = this.store.createRecord('fare', {
        origin: {
          address: origin.val(),
          longitude: origin.data('longitude'),
          latitude: origin.data('latitude'),
          country: origin.data('country'),
          state: origin.data('state'),
          city: origin.data('city')
        },
        destination: {
          address: destination.val(),
          longitude: destination.data('longitude'),
          latitude: destination.data('latitude'),
          country: destination.data('country'),
          state: destination.data('state'),
          city: destination.data('city')
        }
      });

      var onSuccess = function (fare) {
			  that.transitionToRoute('fares-results');
			};

			var onFail = function (fare) {
        that.transitionToRoute('fares-errors');
      };

      fareRequest.save().then(onSuccess, onFail);
      this.send('loadingState');
    }
  }
});